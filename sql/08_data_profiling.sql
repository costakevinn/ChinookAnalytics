-- ============================================================
-- Data Profiling (Core - Deep)
-- Purpose: technical evidence for Data Discovery documentation
-- ============================================================

\pset pager off

-- ------------------------------------------------------------
-- 1) Core entity inventory (row counts)
-- ------------------------------------------------------------
SELECT 'core.customer' t, COUNT(*) rows FROM core.customer
UNION ALL SELECT 'core.employee', COUNT(*) FROM core.employee
UNION ALL SELECT 'core.artist', COUNT(*) FROM core.artist
UNION ALL SELECT 'core.album', COUNT(*) FROM core.album
UNION ALL SELECT 'core.track', COUNT(*) FROM core.track
UNION ALL SELECT 'core.genre', COUNT(*) FROM core.genre
UNION ALL SELECT 'core.mediatype', COUNT(*) FROM core.mediatype
UNION ALL SELECT 'core.invoice', COUNT(*) FROM core.invoice
UNION ALL SELECT 'core.invoiceline', COUNT(*) FROM core.invoiceline
UNION ALL SELECT 'core.playlist', COUNT(*) FROM core.playlist
UNION ALL SELECT 'core.playlisttrack', COUNT(*) FROM core.playlisttrack
ORDER BY t;


-- ------------------------------------------------------------
-- 2) Column catalog (schema, table, column, type, nullable)
-- ------------------------------------------------------------
SELECT
  table_schema,
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'core'
ORDER BY table_name, ordinal_position;


-- ------------------------------------------------------------
-- 3) Constraint catalog (PK/FK/UNIQUE/CHECK)
-- ------------------------------------------------------------
SELECT
  tc.table_schema,
  tc.table_name,
  tc.constraint_name,
  tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'core'
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;

-- FK detail (source -> target)
SELECT
  tc.table_name              AS source_table,
  kcu.column_name            AS source_column,
  ccu.table_name             AS target_table,
  ccu.column_name            AS target_column,
  tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
 AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
 AND ccu.table_schema = tc.table_schema
WHERE tc.table_schema = 'core'
  AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY source_table, source_column;


-- ------------------------------------------------------------
-- 4) Null profiling (core) - key business fields
-- ------------------------------------------------------------
-- Invoice critical fields
SELECT
  COUNT(*) FILTER (WHERE invoice_id IS NULL)    AS invoice_id_nulls,
  COUNT(*) FILTER (WHERE customer_id IS NULL)   AS customer_id_nulls,
  COUNT(*) FILTER (WHERE invoice_date IS NULL)  AS invoice_date_nulls,
  COUNT(*) FILTER (WHERE total IS NULL)         AS total_nulls
FROM core.invoice;

-- InvoiceLine critical fields
SELECT
  COUNT(*) FILTER (WHERE invoice_line_id IS NULL) AS invoice_line_id_nulls,
  COUNT(*) FILTER (WHERE invoice_id IS NULL)      AS invoice_id_nulls,
  COUNT(*) FILTER (WHERE track_id IS NULL)        AS track_id_nulls,
  COUNT(*) FILTER (WHERE unit_price IS NULL)      AS unit_price_nulls,
  COUNT(*) FILTER (WHERE quantity IS NULL)        AS quantity_nulls
FROM core.invoiceline;

-- Customer profile fields
SELECT
  COUNT(*) FILTER (WHERE email IS NULL OR TRIM(email) = '') AS email_missing,
  COUNT(*) FILTER (WHERE country IS NULL OR TRIM(country) = '') AS country_missing
FROM core.customer;


-- ------------------------------------------------------------
-- 5) Uniqueness checks (PK viability reaffirmation)
-- ------------------------------------------------------------
SELECT COUNT(*) rows, COUNT(DISTINCT invoice_id) distinct_ids
FROM core.invoice;

SELECT COUNT(*) rows, COUNT(DISTINCT invoice_line_id) distinct_ids
FROM core.invoiceline;

SELECT COUNT(*) rows, COUNT(DISTINCT track_id) distinct_ids
FROM core.track;

SELECT COUNT(*) rows, COUNT(DISTINCT customer_id) distinct_ids
FROM core.customer;


-- ------------------------------------------------------------
-- 6) Referential integrity checks (should be 0)
-- ------------------------------------------------------------
SELECT COUNT(*) AS invoices_missing_customer
FROM core.invoice i
LEFT JOIN core.customer c ON c.customer_id = i.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS invoicelines_missing_invoice
FROM core.invoiceline il
LEFT JOIN core.invoice i ON i.invoice_id = il.invoice_id
WHERE i.invoice_id IS NULL;

SELECT COUNT(*) AS invoicelines_missing_track
FROM core.invoiceline il
LEFT JOIN core.track t ON t.track_id = il.track_id
WHERE t.track_id IS NULL;

SELECT COUNT(*) AS tracks_missing_album
FROM core.track t
LEFT JOIN core.album a ON a.album_id = t.album_id
WHERE a.album_id IS NULL;

SELECT COUNT(*) AS albums_missing_artist
FROM core.album a
LEFT JOIN core.artist ar ON ar.artist_id = a.artist_id
WHERE ar.artist_id IS NULL;


-- ------------------------------------------------------------
-- 7) Temporal coverage and distribution
-- ------------------------------------------------------------
SELECT
  MIN(invoice_date) AS min_date,
  MAX(invoice_date) AS max_date,
  COUNT(DISTINCT DATE_TRUNC('year', invoice_date)) AS distinct_years,
  COUNT(DISTINCT DATE_TRUNC('month', invoice_date)) AS distinct_months
FROM core.invoice;

SELECT
  DATE_TRUNC('year', invoice_date)::date AS year,
  COUNT(*) AS invoices,
  SUM(total) AS revenue,
  ROUND(AVG(total)::numeric, 2) AS avg_invoice_value
FROM core.invoice
GROUP BY 1
ORDER BY 1;

SELECT
  DATE_TRUNC('month', invoice_date)::date AS month,
  COUNT(*) AS invoices,
  SUM(total) AS revenue,
  ROUND(AVG(total)::numeric, 2) AS avg_invoice_value
FROM core.invoice
GROUP BY 1
ORDER BY 1;


-- ------------------------------------------------------------
-- 8) Geographic coverage and distribution
-- ------------------------------------------------------------
SELECT COUNT(DISTINCT billing_country) AS distinct_billing_countries
FROM core.invoice;

SELECT
  billing_country AS country,
  COUNT(*) AS invoices,
  SUM(total) AS revenue,
  ROUND(AVG(total)::numeric, 2) AS avg_invoice_value
FROM core.invoice
GROUP BY billing_country
ORDER BY revenue DESC;

-- Customer countries (may differ from billing)
SELECT COUNT(DISTINCT country) AS distinct_customer_countries
FROM core.customer;

SELECT
  country,
  COUNT(*) AS customers
FROM core.customer
GROUP BY country
ORDER BY customers DESC, country;


-- ------------------------------------------------------------
-- 9) Revenue / invoice value distribution
-- ------------------------------------------------------------
SELECT
  MIN(total) AS min_total,
  MAX(total) AS max_total,
  ROUND(AVG(total)::numeric, 2) AS avg_total
FROM core.invoice;

SELECT
  percentile_cont(0.25) WITHIN GROUP (ORDER BY total) AS p25,
  percentile_cont(0.50) WITHIN GROUP (ORDER BY total) AS median,
  percentile_cont(0.75) WITHIN GROUP (ORDER BY total) AS p75,
  percentile_cont(0.90) WITHIN GROUP (ORDER BY total) AS p90,
  percentile_cont(0.95) WITHIN GROUP (ORDER BY total) AS p95
FROM core.invoice;

-- Top invoices (largest baskets)
SELECT
  invoice_id,
  customer_id,
  invoice_date,
  billing_country,
  total
FROM core.invoice
ORDER BY total DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 10) Customer purchasing distribution + concentration
-- ------------------------------------------------------------
SELECT
  COUNT(*) AS customers
FROM core.customer;

SELECT
  MIN(invoice_count) AS min_invoices_per_customer,
  MAX(invoice_count) AS max_invoices_per_customer,
  ROUND(AVG(invoice_count)::numeric, 2) AS avg_invoices_per_customer
FROM (
  SELECT customer_id, COUNT(*) AS invoice_count
  FROM core.invoice
  GROUP BY customer_id
) x;

SELECT
  percentile_cont(0.25) WITHIN GROUP (ORDER BY invoice_count) AS p25,
  percentile_cont(0.50) WITHIN GROUP (ORDER BY invoice_count) AS median,
  percentile_cont(0.75) WITHIN GROUP (ORDER BY invoice_count) AS p75
FROM (
  SELECT customer_id, COUNT(*) AS invoice_count
  FROM core.invoice
  GROUP BY customer_id
) x;

-- Customer LTV distribution
WITH ltv AS (
  SELECT customer_id, SUM(total) AS lifetime_revenue
  FROM core.invoice
  GROUP BY customer_id
)
SELECT
  MIN(lifetime_revenue) AS min_ltv,
  MAX(lifetime_revenue) AS max_ltv,
  ROUND(AVG(lifetime_revenue)::numeric, 2) AS avg_ltv,
  percentile_cont(0.50) WITHIN GROUP (ORDER BY lifetime_revenue) AS median_ltv
FROM ltv;

-- Concentration: top 10 / top 20 share of revenue (by customer)
WITH ltv AS (
  SELECT customer_id, SUM(total) AS lifetime_revenue
  FROM core.invoice
  GROUP BY customer_id
),
tot AS (
  SELECT SUM(lifetime_revenue) AS total_rev FROM ltv
),
top10 AS (
  SELECT SUM(lifetime_revenue) AS rev FROM (SELECT lifetime_revenue FROM ltv ORDER BY lifetime_revenue DESC LIMIT 10) t
),
top20 AS (
  SELECT SUM(lifetime_revenue) AS rev FROM (SELECT lifetime_revenue FROM ltv ORDER BY lifetime_revenue DESC LIMIT 20) t
)
SELECT
  ROUND((top10.rev / tot.total_rev)::numeric, 4) AS top10_customer_share,
  ROUND((top20.rev / tot.total_rev)::numeric, 4) AS top20_customer_share
FROM tot, top10, top20;


-- ------------------------------------------------------------
-- 11) Product catalog profiling (coverage + pricing)
-- ------------------------------------------------------------
SELECT
  COUNT(*) AS artists,
  (SELECT COUNT(*) FROM core.album) AS albums,
  (SELECT COUNT(*) FROM core.track) AS tracks
FROM core.artist;

SELECT
  COUNT(*) FILTER (WHERE genre_id IS NULL) AS tracks_without_genre,
  COUNT(*) AS total_tracks
FROM core.track;

SELECT
  MIN(unit_price) AS min_track_price,
  MAX(unit_price) AS max_track_price,
  ROUND(AVG(unit_price)::numeric, 2) AS avg_track_price
FROM core.track;

-- Track duration distribution (milliseconds)
SELECT
  MIN(milliseconds) AS min_ms,
  MAX(milliseconds) AS max_ms,
  ROUND(AVG(milliseconds)::numeric, 0) AS avg_ms
FROM core.track;

SELECT
  percentile_cont(0.50) WITHIN GROUP (ORDER BY milliseconds) AS median_ms,
  percentile_cont(0.90) WITHIN GROUP (ORDER BY milliseconds) AS p90_ms
FROM core.track;


-- ------------------------------------------------------------
-- 12) Sales line characteristics (quantity, unit price)
-- ------------------------------------------------------------
SELECT
  MIN(unit_price) AS min_line_unit_price,
  MAX(unit_price) AS max_line_unit_price,
  MIN(quantity)   AS min_qty,
  MAX(quantity)   AS max_qty
FROM core.invoiceline;

-- Quantity distribution (should reveal if always 1)
SELECT quantity, COUNT(*) AS lines
FROM core.invoiceline
GROUP BY quantity
ORDER BY quantity;


-- ------------------------------------------------------------
-- 13) Revenue by artist / genre (capability evidence)
-- ------------------------------------------------------------
SELECT
  ar.artist_id,
  COALESCE(ar.name, '(unknown)') AS artist,
  SUM(il.unit_price * il.quantity) AS revenue,
  SUM(il.quantity) AS units
FROM core.invoiceline il
JOIN core.track t  ON t.track_id = il.track_id
JOIN core.album al ON al.album_id = t.album_id
JOIN core.artist ar ON ar.artist_id = al.artist_id
GROUP BY ar.artist_id, ar.name
ORDER BY revenue DESC
LIMIT 15;

SELECT
  COALESCE(g.name, '(unknown)') AS genre,
  SUM(il.unit_price * il.quantity) AS revenue,
  SUM(il.quantity) AS units
FROM core.invoiceline il
JOIN core.track t ON t.track_id = il.track_id
LEFT JOIN core.genre g ON g.genre_id = t.genre_id
GROUP BY g.name
ORDER BY revenue DESC;


-- ------------------------------------------------------------
-- 14) Playlist coverage (optional dimension)
-- ------------------------------------------------------------
SELECT
  COUNT(*) AS playlists,
  (SELECT COUNT(*) FROM core.playlisttrack) AS playlist_tracks
FROM core.playlist;

SELECT
  p.playlist_id,
  COALESCE(p.name, '(unknown)') AS playlist,
  COUNT(*) AS tracks
FROM core.playlisttrack pt
JOIN core.playlist p ON p.playlist_id = pt.playlist_id
GROUP BY p.playlist_id, p.name
ORDER BY tracks DESC
LIMIT 10;
