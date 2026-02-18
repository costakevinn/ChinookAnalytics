-- ============================================================
-- 09_add_marts_constraints.sql
-- ChinookAnalytics — marts layer (constraints only)
-- ============================================================

BEGIN;

-- ------------------------
-- NOT NULLs + PRIMARY KEYs
-- ------------------------

-- 1) mart_revenue_time
ALTER TABLE marts.mart_revenue_time
  ALTER COLUMN month_date        SET NOT NULL,
  ALTER COLUMN year_date         SET NOT NULL,
  ALTER COLUMN invoices          SET NOT NULL,
  ALTER COLUMN revenue           SET NOT NULL,
  ALTER COLUMN avg_invoice_value SET NOT NULL;

ALTER TABLE marts.mart_revenue_time
  ADD CONSTRAINT mart_revenue_time_pkey PRIMARY KEY (month_date);

-- 2) mart_market_performance
ALTER TABLE marts.mart_market_performance
  ALTER COLUMN billing_country      SET NOT NULL,
  ALTER COLUMN invoices             SET NOT NULL,
  ALTER COLUMN revenue              SET NOT NULL,
  ALTER COLUMN avg_invoice_value    SET NOT NULL,
  ALTER COLUMN customers            SET NOT NULL,
  ALTER COLUMN revenue_per_customer SET NOT NULL,
  ALTER COLUMN revenue_share        SET NOT NULL;

ALTER TABLE marts.mart_market_performance
  ADD CONSTRAINT mart_market_performance_pkey PRIMARY KEY (billing_country);

-- 3) mart_customer_economics
ALTER TABLE marts.mart_customer_economics
  ALTER COLUMN customer_id       SET NOT NULL,
  ALTER COLUMN invoices          SET NOT NULL,
  ALTER COLUMN ltv               SET NOT NULL,
  ALTER COLUMN avg_invoice_value SET NOT NULL;

ALTER TABLE marts.mart_customer_economics
  ADD CONSTRAINT mart_customer_economics_pkey PRIMARY KEY (customer_id);

-- 4) mart_portfolio_artist
ALTER TABLE marts.mart_portfolio_artist
  ALTER COLUMN artist_id     SET NOT NULL,
  ALTER COLUMN units         SET NOT NULL,
  ALTER COLUMN revenue       SET NOT NULL,
  ALTER COLUMN revenue_share SET NOT NULL;

ALTER TABLE marts.mart_portfolio_artist
  ADD CONSTRAINT mart_portfolio_artist_pkey PRIMARY KEY (artist_id);

-- 5) mart_portfolio_genre
ALTER TABLE marts.mart_portfolio_genre
  ALTER COLUMN genre_id      SET NOT NULL,
  ALTER COLUMN units         SET NOT NULL,
  ALTER COLUMN revenue       SET NOT NULL,
  ALTER COLUMN revenue_share SET NOT NULL;

ALTER TABLE marts.mart_portfolio_genre
  ADD CONSTRAINT mart_portfolio_genre_pkey PRIMARY KEY (genre_id);

-- 6) mart_revenue_composition
ALTER TABLE marts.mart_revenue_composition
  ALTER COLUMN invoice_id           SET NOT NULL,
  ALTER COLUMN customer_id          SET NOT NULL,
  ALTER COLUMN invoice_date         SET NOT NULL,
  ALTER COLUMN month_date           SET NOT NULL,
  ALTER COLUMN invoice_total        SET NOT NULL,
  ALTER COLUMN lines                SET NOT NULL,
  ALTER COLUMN units                SET NOT NULL,
  ALTER COLUMN distinct_tracks      SET NOT NULL,
  ALTER COLUMN distinct_artists     SET NOT NULL,
  ALTER COLUMN distinct_genres      SET NOT NULL,
  ALTER COLUMN distinct_media_types SET NOT NULL;

ALTER TABLE marts.mart_revenue_composition
  ADD CONSTRAINT mart_revenue_composition_pkey PRIMARY KEY (invoice_id);

-- 7) mart_dependency_summary
ALTER TABLE marts.mart_dependency_summary
  ALTER COLUMN snapshot_date        SET NOT NULL,
  ALTER COLUMN total_revenue        SET NOT NULL,
  ALTER COLUMN top1_artist_share    SET NOT NULL,
  ALTER COLUMN top5_artist_share    SET NOT NULL,
  ALTER COLUMN top10_artist_share   SET NOT NULL,
  ALTER COLUMN top1_country_share   SET NOT NULL,
  ALTER COLUMN top5_country_share   SET NOT NULL,
  ALTER COLUMN top10_country_share  SET NOT NULL,
  ALTER COLUMN top10_customer_share SET NOT NULL,
  ALTER COLUMN top20_customer_share SET NOT NULL;

ALTER TABLE marts.mart_dependency_summary
  ADD CONSTRAINT mart_dependency_summary_pkey PRIMARY KEY (snapshot_date);

-- ------------------------
-- CHECK constraints (sane ranges)
-- ------------------------

ALTER TABLE marts.mart_revenue_time
  ADD CONSTRAINT mart_revenue_time_invoices_check CHECK (invoices >= 0),
  ADD CONSTRAINT mart_revenue_time_revenue_check  CHECK (revenue >= 0),
  ADD CONSTRAINT mart_revenue_time_aiv_check      CHECK (avg_invoice_value >= 0);

ALTER TABLE marts.mart_market_performance
  ADD CONSTRAINT mart_market_invoices_check CHECK (invoices >= 0),
  ADD CONSTRAINT mart_market_revenue_check  CHECK (revenue >= 0),
  ADD CONSTRAINT mart_market_customers_check CHECK (customers >= 0),
  ADD CONSTRAINT mart_market_rpc_check      CHECK (revenue_per_customer >= 0),
  ADD CONSTRAINT mart_market_share_check    CHECK (revenue_share >= 0 AND revenue_share <= 1);

ALTER TABLE marts.mart_customer_economics
  ADD CONSTRAINT mart_customer_invoices_check CHECK (invoices >= 0),
  ADD CONSTRAINT mart_customer_ltv_check      CHECK (ltv >= 0),
  ADD CONSTRAINT mart_customer_aiv_check      CHECK (avg_invoice_value >= 0);

ALTER TABLE marts.mart_portfolio_artist
  ADD CONSTRAINT mart_artist_units_check CHECK (units >= 0),
  ADD CONSTRAINT mart_artist_revenue_check CHECK (revenue >= 0),
  ADD CONSTRAINT mart_artist_share_check CHECK (revenue_share >= 0 AND revenue_share <= 1);

ALTER TABLE marts.mart_portfolio_genre
  ADD CONSTRAINT mart_genre_units_check CHECK (units >= 0),
  ADD CONSTRAINT mart_genre_revenue_check CHECK (revenue >= 0),
  ADD CONSTRAINT mart_genre_share_check CHECK (revenue_share >= 0 AND revenue_share <= 1);

ALTER TABLE marts.mart_revenue_composition
  ADD CONSTRAINT mart_comp_total_check CHECK (invoice_total >= 0),
  ADD CONSTRAINT mart_comp_lines_check CHECK (lines >= 0),
  ADD CONSTRAINT mart_comp_units_check CHECK (units >= 0),
  ADD CONSTRAINT mart_comp_distinct_tracks_check CHECK (distinct_tracks >= 0),
  ADD CONSTRAINT mart_comp_distinct_artists_check CHECK (distinct_artists >= 0),
  ADD CONSTRAINT mart_comp_distinct_genres_check CHECK (distinct_genres >= 0),
  ADD CONSTRAINT mart_comp_distinct_media_types_check CHECK (distinct_media_types >= 0);

ALTER TABLE marts.mart_dependency_summary
  ADD CONSTRAINT mart_dep_total_revenue_check CHECK (total_revenue >= 0),
  ADD CONSTRAINT mart_dep_share_bounds_check CHECK (
    top1_artist_share BETWEEN 0 AND 1 AND
    top5_artist_share BETWEEN 0 AND 1 AND
    top10_artist_share BETWEEN 0 AND 1 AND
    top1_country_share BETWEEN 0 AND 1 AND
    top5_country_share BETWEEN 0 AND 1 AND
    top10_country_share BETWEEN 0 AND 1 AND
    top10_customer_share BETWEEN 0 AND 1 AND
    top20_customer_share BETWEEN 0 AND 1
  );

-- ------------------------
-- FOREIGN KEYS (optional but recommended; ties marts back to core)
-- ------------------------

ALTER TABLE marts.mart_customer_economics
  ADD CONSTRAINT mart_customer_economics_customer_id_fkey
  FOREIGN KEY (customer_id) REFERENCES core.customer(customer_id);

ALTER TABLE marts.mart_portfolio_artist
  ADD CONSTRAINT mart_portfolio_artist_artist_id_fkey
  FOREIGN KEY (artist_id) REFERENCES core.artist(artist_id);

ALTER TABLE marts.mart_portfolio_genre
  ADD CONSTRAINT mart_portfolio_genre_genre_id_fkey
  FOREIGN KEY (genre_id) REFERENCES core.genre(genre_id);

ALTER TABLE marts.mart_revenue_composition
  ADD CONSTRAINT mart_revenue_composition_invoice_id_fkey
  FOREIGN KEY (invoice_id) REFERENCES core.invoice(invoice_id);

ALTER TABLE marts.mart_revenue_composition
  ADD CONSTRAINT mart_revenue_composition_customer_id_fkey
  FOREIGN KEY (customer_id) REFERENCES core.customer(customer_id);

COMMIT;
