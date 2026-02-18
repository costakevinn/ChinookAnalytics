-- Core tables (constraints only) - PK/FK/CHECK/NOT NULL here

BEGIN;

-- ------------------------
-- NOT NULL requirements
-- ------------------------
ALTER TABLE core.customer
  ALTER COLUMN customer_id SET NOT NULL,
  ALTER COLUMN first_name  SET NOT NULL,
  ALTER COLUMN last_name   SET NOT NULL;

ALTER TABLE core.employee
  ALTER COLUMN employee_id SET NOT NULL,
  ALTER COLUMN last_name   SET NOT NULL,
  ALTER COLUMN first_name  SET NOT NULL;

ALTER TABLE core.artist
  ALTER COLUMN artist_id SET NOT NULL;

ALTER TABLE core.album
  ALTER COLUMN album_id  SET NOT NULL,
  ALTER COLUMN title     SET NOT NULL,
  ALTER COLUMN artist_id SET NOT NULL;

ALTER TABLE core.genre
  ALTER COLUMN genre_id SET NOT NULL;

ALTER TABLE core.mediatype
  ALTER COLUMN media_type_id SET NOT NULL;

ALTER TABLE core.track
  ALTER COLUMN track_id      SET NOT NULL,
  ALTER COLUMN name          SET NOT NULL,
  ALTER COLUMN album_id      SET NOT NULL,
  ALTER COLUMN media_type_id SET NOT NULL,
  ALTER COLUMN unit_price    SET NOT NULL;

ALTER TABLE core.invoice
  ALTER COLUMN invoice_id   SET NOT NULL,
  ALTER COLUMN customer_id  SET NOT NULL,
  ALTER COLUMN invoice_date SET NOT NULL,
  ALTER COLUMN total        SET NOT NULL;

ALTER TABLE core.invoiceline
  ALTER COLUMN invoice_line_id SET NOT NULL,
  ALTER COLUMN invoice_id      SET NOT NULL,
  ALTER COLUMN track_id        SET NOT NULL,
  ALTER COLUMN unit_price      SET NOT NULL,
  ALTER COLUMN quantity        SET NOT NULL;

ALTER TABLE core.playlist
  ALTER COLUMN playlist_id SET NOT NULL;

ALTER TABLE core.playlisttrack
  ALTER COLUMN playlist_id SET NOT NULL,
  ALTER COLUMN track_id    SET NOT NULL;

-- ------------------------
-- PRIMARY KEYS
-- ------------------------
ALTER TABLE core.customer      ADD CONSTRAINT customer_pkey      PRIMARY KEY (customer_id);
ALTER TABLE core.employee      ADD CONSTRAINT employee_pkey      PRIMARY KEY (employee_id);
ALTER TABLE core.artist        ADD CONSTRAINT artist_pkey        PRIMARY KEY (artist_id);
ALTER TABLE core.album         ADD CONSTRAINT album_pkey         PRIMARY KEY (album_id);
ALTER TABLE core.genre         ADD CONSTRAINT genre_pkey         PRIMARY KEY (genre_id);
ALTER TABLE core.mediatype     ADD CONSTRAINT mediatype_pkey     PRIMARY KEY (media_type_id);
ALTER TABLE core.track         ADD CONSTRAINT track_pkey         PRIMARY KEY (track_id);
ALTER TABLE core.invoice       ADD CONSTRAINT invoice_pkey       PRIMARY KEY (invoice_id);
ALTER TABLE core.invoiceline   ADD CONSTRAINT invoiceline_pkey   PRIMARY KEY (invoice_line_id);
ALTER TABLE core.playlist      ADD CONSTRAINT playlist_pkey      PRIMARY KEY (playlist_id);
ALTER TABLE core.playlisttrack ADD CONSTRAINT playlisttrack_pkey PRIMARY KEY (playlist_id, track_id);

-- ------------------------
-- CHECK constraints
-- ------------------------
ALTER TABLE core.track
  ADD CONSTRAINT track_unit_price_check CHECK (unit_price >= 0);

ALTER TABLE core.invoice
  ADD CONSTRAINT invoice_total_check CHECK (total >= 0);

ALTER TABLE core.invoiceline
  ADD CONSTRAINT invoiceline_unit_price_check CHECK (unit_price >= 0),
  ADD CONSTRAINT invoiceline_quantity_check   CHECK (quantity > 0);

-- ------------------------
-- FOREIGN KEYS
-- ------------------------
ALTER TABLE core.album
  ADD CONSTRAINT album_artist_id_fkey
  FOREIGN KEY (artist_id) REFERENCES core.artist(artist_id);

ALTER TABLE core.track
  ADD CONSTRAINT track_album_id_fkey
  FOREIGN KEY (album_id) REFERENCES core.album(album_id);

ALTER TABLE core.track
  ADD CONSTRAINT track_media_type_id_fkey
  FOREIGN KEY (media_type_id) REFERENCES core.mediatype(media_type_id);

ALTER TABLE core.track
  ADD CONSTRAINT track_genre_id_fkey
  FOREIGN KEY (genre_id) REFERENCES core.genre(genre_id);

ALTER TABLE core.invoice
  ADD CONSTRAINT invoice_customer_id_fkey
  FOREIGN KEY (customer_id) REFERENCES core.customer(customer_id);

ALTER TABLE core.invoiceline
  ADD CONSTRAINT invoiceline_invoice_id_fkey
  FOREIGN KEY (invoice_id) REFERENCES core.invoice(invoice_id);

ALTER TABLE core.invoiceline
  ADD CONSTRAINT invoiceline_track_id_fkey
  FOREIGN KEY (track_id) REFERENCES core.track(track_id);

ALTER TABLE core.playlisttrack
  ADD CONSTRAINT playlisttrack_playlist_id_fkey
  FOREIGN KEY (playlist_id) REFERENCES core.playlist(playlist_id);

ALTER TABLE core.playlisttrack
  ADD CONSTRAINT playlisttrack_track_id_fkey
  FOREIGN KEY (track_id) REFERENCES core.track(track_id);

-- (Optional but consistent with your model)
ALTER TABLE core.customer
  ADD CONSTRAINT customer_support_rep_id_fkey
  FOREIGN KEY (support_rep_id) REFERENCES core.employee(employee_id);

ALTER TABLE core.employee
  ADD CONSTRAINT employee_reports_to_fkey
  FOREIGN KEY (reports_to) REFERENCES core.employee(employee_id);

COMMIT;
