-- ============================================================
-- EDA (Structural) — Staging
-- Purpose: validate raw load before defining core constraints
-- ============================================================

\pset pager off


-- ------------------------------------------------------------
-- 1) Row counts (sanity)
-- ------------------------------------------------------------
SELECT 'album' t, COUNT(*) rows FROM stg.album
UNION ALL SELECT 'artist', COUNT(*) FROM stg.artist
UNION ALL SELECT 'customer', COUNT(*) FROM stg.customer
UNION ALL SELECT 'employee', COUNT(*) FROM stg.employee
UNION ALL SELECT 'genre', COUNT(*) FROM stg.genre
UNION ALL SELECT 'invoice', COUNT(*) FROM stg.invoice
UNION ALL SELECT 'invoiceline', COUNT(*) FROM stg.invoiceline
UNION ALL SELECT 'mediatype', COUNT(*) FROM stg.mediatype
UNION ALL SELECT 'playlist', COUNT(*) FROM stg.playlist
UNION ALL SELECT 'playlisttrack', COUNT(*) FROM stg.playlisttrack
UNION ALL SELECT 'track', COUNT(*) FROM stg.track
ORDER BY t;


-- ------------------------------------------------------------
-- 2) ID uniqueness (PK viability)
-- ------------------------------------------------------------
SELECT 'invoice.invoiceid' key, COUNT(*) total, COUNT(DISTINCT invoiceid) distinct_ids
FROM stg.invoice;

SELECT 'invoiceline.invoicelineid' key, COUNT(*) total, COUNT(DISTINCT invoicelineid) distinct_ids
FROM stg.invoiceline;

SELECT 'customer.customerid' key, COUNT(*) total, COUNT(DISTINCT customerid) distinct_ids
FROM stg.customer;

SELECT 'track.trackid' key, COUNT(*) total, COUNT(DISTINCT trackid) distinct_ids
FROM stg.track;


-- ------------------------------------------------------------
-- 3) Null checks (critical columns)
-- ------------------------------------------------------------
SELECT
  COUNT(*) FILTER (WHERE customerid IS NULL)  AS customerid_nulls,
  COUNT(*) FILTER (WHERE invoicedate IS NULL) AS invoicedate_nulls,
  COUNT(*) FILTER (WHERE total IS NULL)       AS total_nulls
FROM stg.invoice;

SELECT
  COUNT(*) FILTER (WHERE invoiceid IS NULL) AS invoiceid_nulls,
  COUNT(*) FILTER (WHERE trackid IS NULL)   AS trackid_nulls,
  COUNT(*) FILTER (WHERE unitprice IS NULL) AS unitprice_nulls,
  COUNT(*) FILTER (WHERE quantity IS NULL)  AS quantity_nulls
FROM stg.invoiceline;


-- ------------------------------------------------------------
-- 4) Orphan checks (FK viability)
-- ------------------------------------------------------------
SELECT COUNT(*) AS orphan_invoice_customer
FROM stg.invoice i
LEFT JOIN stg.customer c ON c.customerid = i.customerid
WHERE c.customerid IS NULL;

SELECT COUNT(*) AS orphan_invoiceline_invoice
FROM stg.invoiceline il
LEFT JOIN stg.invoice i ON i.invoiceid = il.invoiceid
WHERE i.invoiceid IS NULL;

SELECT COUNT(*) AS orphan_invoiceline_track
FROM stg.invoiceline il
LEFT JOIN stg.track t ON t.trackid = il.trackid
WHERE t.trackid IS NULL;


-- ------------------------------------------------------------
-- 5) Date + value sanity
-- ------------------------------------------------------------
SELECT MIN(invoicedate) AS min_date, MAX(invoicedate) AS max_date
FROM stg.invoice;

SELECT
  COUNT(*) FILTER (WHERE total < 0) AS negative_total,
  MIN(total) AS min_total,
  MAX(total) AS max_total
FROM stg.invoice;

SELECT
  COUNT(*) FILTER (WHERE unitprice < 0) AS negative_unitprice,
  COUNT(*) FILTER (WHERE quantity <= 0) AS nonpositive_qty
FROM stg.invoiceline;
