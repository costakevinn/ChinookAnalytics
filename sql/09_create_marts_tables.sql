-- ============================================================
-- 08_create_marts_tables.sql
-- ChinookAnalytics — marts layer (DDL only, NO constraints)
-- ============================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS marts;

-- Drop (idempotent)
DROP TABLE IF EXISTS marts.mart_dependency_summary     CASCADE;
DROP TABLE IF EXISTS marts.mart_revenue_composition    CASCADE;
DROP TABLE IF EXISTS marts.mart_portfolio_genre        CASCADE;
DROP TABLE IF EXISTS marts.mart_portfolio_artist       CASCADE;
DROP TABLE IF EXISTS marts.mart_customer_economics     CASCADE;
DROP TABLE IF EXISTS marts.mart_market_performance     CASCADE;
DROP TABLE IF EXISTS marts.mart_revenue_time           CASCADE;

-- ============================================================
-- 1) Revenue over time (month grain)
-- ============================================================
CREATE TABLE marts.mart_revenue_time (
  month_date            date,
  year_date             date,
  invoices              integer,
  revenue               numeric(12,2),
  avg_invoice_value     numeric(12,4),
  mom_revenue_growth    numeric(18,8),
  yoy_revenue_growth    numeric(18,8)
);

-- ============================================================
-- 2) Market performance (billing country grain)
-- ============================================================
CREATE TABLE marts.mart_market_performance (
  billing_country       text,
  invoices              integer,
  revenue               numeric(12,2),
  avg_invoice_value     numeric(12,4),
  customers             integer,
  revenue_per_customer  numeric(12,4),
  revenue_share         numeric(18,8)
);

-- ============================================================
-- 3) Customer economics (customer grain)
-- ============================================================
CREATE TABLE marts.mart_customer_economics (
  customer_id           integer,
  first_name            text,
  last_name             text,
  country               text,
  invoices              integer,
  ltv                   numeric(12,2),
  avg_invoice_value     numeric(12,4),
  first_purchase_date   timestamp without time zone,
  last_purchase_date    timestamp without time zone
);

-- ============================================================
-- 4) Portfolio — artist (artist grain)
-- ============================================================
CREATE TABLE marts.mart_portfolio_artist (
  artist_id             integer,
  artist_name           text,
  units                 integer,
  revenue               numeric(12,2),
  revenue_share         numeric(18,8)
);

-- ============================================================
-- 5) Portfolio — genre (genre grain)
-- ============================================================
CREATE TABLE marts.mart_portfolio_genre (
  genre_id              integer,
  genre_name            text,
  units                 integer,
  revenue               numeric(12,2),
  revenue_share         numeric(18,8)
);

-- ============================================================
-- 6) Invoice composition (invoice grain)
-- ============================================================
CREATE TABLE marts.mart_revenue_composition (
  invoice_id            integer,
  customer_id           integer,
  invoice_date          timestamp without time zone,
  month_date            date,
  billing_country       text,
  invoice_total         numeric(12,2),
  lines                 integer,
  units                 integer,
  distinct_tracks       integer,
  distinct_artists      integer,
  distinct_genres       integer,
  distinct_media_types  integer
);

-- ============================================================
-- 7) Dependency summary (single snapshot row)
-- ============================================================
CREATE TABLE marts.mart_dependency_summary (
  snapshot_date         date,
  total_revenue         numeric(12,2),
  top1_artist_share     numeric(18,8),
  top5_artist_share     numeric(18,8),
  top10_artist_share    numeric(18,8),
  top1_country_share    numeric(18,8),
  top5_country_share    numeric(18,8),
  top10_country_share   numeric(18,8),
  top10_customer_share  numeric(18,8),
  top20_customer_share  numeric(18,8)
);

COMMIT;
