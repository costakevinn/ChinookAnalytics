-- ============================================================
-- 09_load_marts.sql
-- ChinookAnalytics — marts layer (DML only)
-- ============================================================

BEGIN;

TRUNCATE TABLE
  marts.mart_revenue_time,
  marts.mart_market_performance,
  marts.mart_customer_economics,
  marts.mart_portfolio_artist,
  marts.mart_portfolio_genre,
  marts.mart_revenue_composition,
  marts.mart_dependency_summary;

-- ============================================================
-- 1) mart_revenue_time (month grain)
-- ============================================================
WITH base AS (
  SELECT
    date_trunc('month', i.invoice_date)::date AS month_date,
    date_trunc('year',  i.invoice_date)::date AS year_date,
    COUNT(*)::int AS invoices,
    SUM(i.total)::numeric(12,2) AS revenue,
    AVG(i.total)::numeric(12,4) AS avg_invoice_value
  FROM core.invoice i
  GROUP BY 1,2
),
growth AS (
  SELECT
    b.*,
    LAG(b.revenue) OVER (ORDER BY b.month_date) AS prev_rev,
    LAG(b.revenue, 12) OVER (ORDER BY b.month_date) AS prev_rev_12
  FROM base b
)
INSERT INTO marts.mart_revenue_time (
  month_date, year_date, invoices, revenue, avg_invoice_value,
  mom_revenue_growth, yoy_revenue_growth
)
SELECT
  month_date,
  year_date,
  invoices,
  revenue,
  avg_invoice_value,
  CASE
    WHEN prev_rev IS NULL OR prev_rev = 0 THEN NULL
    ELSE (revenue - prev_rev) / prev_rev
  END AS mom_revenue_growth,
  CASE
    WHEN prev_rev_12 IS NULL OR prev_rev_12 = 0 THEN NULL
    ELSE (revenue - prev_rev_12) / prev_rev_12
  END AS yoy_revenue_growth
FROM growth
ORDER BY month_date;

-- ============================================================
-- 2) mart_market_performance (billing_country grain)
-- ============================================================
WITH base AS (
  SELECT
    COALESCE(i.billing_country, 'Unknown') AS billing_country,
    COUNT(*)::int AS invoices,
    SUM(i.total)::numeric(12,2) AS revenue,
    AVG(i.total)::numeric(12,4) AS avg_invoice_value,
    COUNT(DISTINCT i.customer_id)::int AS customers
  FROM core.invoice i
  GROUP BY 1
),
tot AS (
  SELECT SUM(revenue)::numeric(12,2) AS total_revenue FROM base
)
INSERT INTO marts.mart_market_performance (
  billing_country, invoices, revenue, avg_invoice_value, customers,
  revenue_per_customer, revenue_share
)
SELECT
  b.billing_country,
  b.invoices,
  b.revenue,
  b.avg_invoice_value,
  b.customers,
  CASE WHEN b.customers = 0 THEN 0 ELSE (b.revenue / b.customers)::numeric(12,4) END AS revenue_per_customer,
  CASE WHEN t.total_revenue = 0 THEN 0 ELSE (b.revenue / t.total_revenue)::numeric(18,8) END AS revenue_share
FROM base b
CROSS JOIN tot t
ORDER BY b.revenue DESC, b.billing_country;

-- ============================================================
-- 3) mart_customer_economics (customer grain)
-- ============================================================
INSERT INTO marts.mart_customer_economics (
  customer_id, first_name, last_name, country,
  invoices, ltv, avg_invoice_value, first_purchase_date, last_purchase_date
)
SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  c.country,
  COUNT(i.invoice_id)::int AS invoices,
  COALESCE(SUM(i.total),0)::numeric(12,2) AS ltv,
  COALESCE(AVG(i.total),0)::numeric(12,4) AS avg_invoice_value,
  MIN(i.invoice_date) AS first_purchase_date,
  MAX(i.invoice_date) AS last_purchase_date
FROM core.customer c
LEFT JOIN core.invoice i
  ON i.customer_id = c.customer_id
GROUP BY 1,2,3,4
ORDER BY ltv DESC, invoices DESC, c.customer_id;

-- ============================================================
-- 4) mart_portfolio_artist (artist grain)
-- ============================================================
WITH line_fact AS (
  SELECT
    a.artist_id,
    a.name AS artist_name,
    il.quantity::int AS quantity,
    (il.unit_price * il.quantity)::numeric(12,2) AS line_revenue
  FROM core.invoiceline il
  JOIN core.track t       ON t.track_id = il.track_id
  JOIN core.album al      ON al.album_id = t.album_id
  JOIN core.artist a      ON a.artist_id = al.artist_id
),
agg AS (
  SELECT
    artist_id,
    artist_name,
    SUM(quantity)::int AS units,
    SUM(line_revenue)::numeric(12,2) AS revenue
  FROM line_fact
  GROUP BY 1,2
),
tot AS (
  SELECT SUM(revenue)::numeric(12,2) AS total_revenue FROM agg
)
INSERT INTO marts.mart_portfolio_artist (artist_id, artist_name, units, revenue, revenue_share)
SELECT
  a.artist_id,
  a.artist_name,
  a.units,
  a.revenue,
  CASE WHEN t.total_revenue = 0 THEN 0 ELSE (a.revenue / t.total_revenue)::numeric(18,8) END AS revenue_share
FROM agg a
CROSS JOIN tot t
ORDER BY a.revenue DESC, a.artist_id;

-- ============================================================
-- 5) mart_portfolio_genre (genre grain)
-- ============================================================
WITH line_fact AS (
  SELECT
    g.genre_id,
    g.name AS genre_name,
    il.quantity::int AS quantity,
    (il.unit_price * il.quantity)::numeric(12,2) AS line_revenue
  FROM core.invoiceline il
  JOIN core.track t  ON t.track_id = il.track_id
  JOIN core.genre g  ON g.genre_id = t.genre_id
),
agg AS (
  SELECT
    genre_id,
    genre_name,
    SUM(quantity)::int AS units,
    SUM(line_revenue)::numeric(12,2) AS revenue
  FROM line_fact
  GROUP BY 1,2
),
tot AS (
  SELECT SUM(revenue)::numeric(12,2) AS total_revenue FROM agg
)
INSERT INTO marts.mart_portfolio_genre (genre_id, genre_name, units, revenue, revenue_share)
SELECT
  a.genre_id,
  a.genre_name,
  a.units,
  a.revenue,
  CASE WHEN t.total_revenue = 0 THEN 0 ELSE (a.revenue / t.total_revenue)::numeric(18,8) END AS revenue_share
FROM agg a
CROSS JOIN tot t
ORDER BY a.revenue DESC, a.genre_id;

-- ============================================================
-- 6) mart_revenue_composition (invoice grain)
-- ============================================================
WITH invoice_lines AS (
  SELECT
    i.invoice_id,
    i.customer_id,
    i.invoice_date,
    date_trunc('month', i.invoice_date)::date AS month_date,
    i.billing_country,
    i.total::numeric(12,2) AS invoice_total,
    il.track_id,
    il.quantity::int AS quantity,
    t.genre_id,
    t.media_type_id,
    a.artist_id
  FROM core.invoice i
  JOIN core.invoiceline il ON il.invoice_id = i.invoice_id
  JOIN core.track t        ON t.track_id = il.track_id
  JOIN core.album al       ON al.album_id = t.album_id
  JOIN core.artist a       ON a.artist_id = al.artist_id
)
INSERT INTO marts.mart_revenue_composition (
  invoice_id, customer_id, invoice_date, month_date, billing_country, invoice_total,
  lines, units, distinct_tracks, distinct_artists, distinct_genres, distinct_media_types
)
SELECT
  invoice_id,
  customer_id,
  invoice_date,
  month_date,
  billing_country,
  invoice_total,
  COUNT(*)::int AS lines,
  SUM(quantity)::int AS units,
  COUNT(DISTINCT track_id)::int AS distinct_tracks,
  COUNT(DISTINCT artist_id)::int AS distinct_artists,
  COUNT(DISTINCT genre_id)::int AS distinct_genres,
  COUNT(DISTINCT media_type_id)::int AS distinct_media_types
FROM invoice_lines
GROUP BY 1,2,3,4,5,6
ORDER BY invoice_date, invoice_id;

-- ============================================================
-- 7) mart_dependency_summary (single snapshot row)
-- ============================================================
WITH total AS (
  SELECT SUM(total)::numeric(12,2) AS total_revenue
  FROM core.invoice
),
artist_rank AS (
  SELECT
    artist_id,
    revenue,
    ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rn
  FROM (
    SELECT
      a.artist_id,
      SUM((il.unit_price * il.quantity))::numeric(12,2) AS revenue
    FROM core.invoiceline il
    JOIN core.track t   ON t.track_id = il.track_id
    JOIN core.album al  ON al.album_id = t.album_id
    JOIN core.artist a  ON a.artist_id = al.artist_id
    GROUP BY 1
  ) x
),
country_rank AS (
  SELECT
    billing_country,
    revenue,
    ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rn
  FROM (
    SELECT
      COALESCE(i.billing_country, 'Unknown') AS billing_country,
      SUM(i.total)::numeric(12,2) AS revenue
    FROM core.invoice i
    GROUP BY 1
  ) x
),
customer_rank AS (
  SELECT
    customer_id,
    revenue,
    ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rn
  FROM (
    SELECT
      i.customer_id,
      SUM(i.total)::numeric(12,2) AS revenue
    FROM core.invoice i
    GROUP BY 1
  ) x
),
shares AS (
  SELECT
    CURRENT_DATE AS snapshot_date,
    t.total_revenue,

    COALESCE((SELECT SUM(revenue) FROM artist_rank  WHERE rn <= 1)  / NULLIF(t.total_revenue,0), 0)::numeric(18,8) AS top1_artist_share,
    COALESCE((SELECT SUM(revenue) FROM artist_rank  WHERE rn <= 5)  / NULLIF(t.total_revenue,0), 0)::numeric(18,8) AS top5_artist_share,
    COALESCE((SELECT SUM(revenue) FROM artist_rank  WHERE rn <= 10) / NULLIF(t.total_revenue,0), 0)::numeric(18,8) AS top10_artist_share,

    COALESCE((SELECT SUM(revenue) FROM country_rank WHERE rn <= 1)  / NULLIF(t.total_revenue,0), 0)::numeric(18,8) AS top1_country_share,
    COALESCE((SELECT SUM(revenue) FROM country_rank WHERE rn <= 5)  / NULLIF(t.total_revenue,0), 0)::numeric(18,8) AS top5_country_share,
    COALESCE((SELECT SUM(revenue) FROM country_rank WHERE rn <= 10) / NULLIF(t.total_revenue,0), 0)::numeric(18,8) AS top10_country_share,

    COALESCE((SELECT SUM(revenue) FROM customer_rank WHERE rn <= 10) / NULLIF(t.total_revenue,0), 0)::numeric(18,8) AS top10_customer_share,
    COALESCE((SELECT SUM(revenue) FROM customer_rank WHERE rn <= 20) / NULLIF(t.total_revenue,0), 0)::numeric(18,8) AS top20_customer_share
  FROM total t
)
INSERT INTO marts.mart_dependency_summary (
  snapshot_date, total_revenue,
  top1_artist_share, top5_artist_share, top10_artist_share,
  top1_country_share, top5_country_share, top10_country_share,
  top10_customer_share, top20_customer_share
)
SELECT
  snapshot_date, total_revenue,
  top1_artist_share, top5_artist_share, top10_artist_share,
  top1_country_share, top5_country_share, top10_country_share,
  top10_customer_share, top20_customer_share
FROM shares;

COMMIT;
