\pset pager off

WITH totals AS (
  SELECT
    (SELECT SUM(total) FROM core.invoice)::numeric(12,2) AS core_rev,
    (SELECT SUM(revenue) FROM marts.mart_revenue_time)::numeric(12,2) AS time_rev,
    (SELECT SUM(revenue) FROM marts.mart_market_performance)::numeric(12,2) AS market_rev,
    (SELECT SUM(ltv) FROM marts.mart_customer_economics)::numeric(12,2) AS customer_rev,
    (SELECT SUM(revenue) FROM marts.mart_portfolio_artist)::numeric(12,2) AS artist_rev,
    (SELECT SUM(revenue) FROM marts.mart_portfolio_genre)::numeric(12,2) AS genre_rev,
    (SELECT SUM(invoice_total) FROM marts.mart_revenue_composition)::numeric(12,2) AS comp_rev,
    (SELECT MAX(total_revenue) FROM marts.mart_dependency_summary)::numeric(12,2) AS dep_rev,
    (SELECT COUNT(*) FROM core.invoice) AS core_invoices,
    (SELECT COUNT(*) FROM marts.mart_revenue_composition) AS comp_invoices
)
SELECT
  *,
  CASE WHEN core_rev = time_rev THEN 'OK' ELSE 'FAIL' END AS chk_time,
  CASE WHEN core_rev = market_rev THEN 'OK' ELSE 'FAIL' END AS chk_market,
  CASE WHEN core_rev = customer_rev THEN 'OK' ELSE 'FAIL' END AS chk_customer,
  CASE WHEN core_rev = artist_rev THEN 'OK' ELSE 'FAIL' END AS chk_artist,
  CASE WHEN core_rev = genre_rev THEN 'OK' ELSE 'FAIL' END AS chk_genre,
  CASE WHEN core_rev = comp_rev THEN 'OK' ELSE 'FAIL' END AS chk_comp,
  CASE WHEN core_rev = dep_rev THEN 'OK' ELSE 'FAIL' END AS chk_dep,
  CASE WHEN core_invoices = comp_invoices THEN 'OK' ELSE 'FAIL' END AS chk_invoice_count
FROM totals;
