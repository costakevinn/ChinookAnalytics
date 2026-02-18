-- Core tables (structure only) - NO constraints here

BEGIN;

CREATE SCHEMA IF NOT EXISTS core;

-- Drop safely (dependencies handled)
DROP TABLE IF EXISTS core.playlisttrack CASCADE;
DROP TABLE IF EXISTS core.playlist      CASCADE;
DROP TABLE IF EXISTS core.invoiceline   CASCADE;
DROP TABLE IF EXISTS core.invoice       CASCADE;
DROP TABLE IF EXISTS core.track         CASCADE;
DROP TABLE IF EXISTS core.album         CASCADE;
DROP TABLE IF EXISTS core.artist        CASCADE;
DROP TABLE IF EXISTS core.customer      CASCADE;
DROP TABLE IF EXISTS core.genre         CASCADE;
DROP TABLE IF EXISTS core.mediatype     CASCADE;
DROP TABLE IF EXISTS core.employee      CASCADE;

CREATE TABLE core.customer (
  customer_id    integer,
  first_name     text,
  last_name      text,
  company        text,
  address        text,
  city           text,
  state          text,
  country        text,
  postal_code    text,
  phone          text,
  fax            text,
  email          text,
  support_rep_id integer
);

CREATE TABLE core.employee (
  employee_id integer,
  last_name   text,
  first_name  text,
  title       text,
  reports_to  integer,
  birth_date  timestamp,
  hire_date   timestamp,
  address     text,
  city        text,
  state       text,
  country     text,
  postal_code text,
  phone       text,
  fax         text,
  email       text
);

CREATE TABLE core.artist (
  artist_id integer,
  name      text
);

CREATE TABLE core.album (
  album_id  integer,
  title     text,
  artist_id integer
);

CREATE TABLE core.genre (
  genre_id integer,
  name     text
);

CREATE TABLE core.mediatype (
  media_type_id integer,
  name          text
);

CREATE TABLE core.track (
  track_id      integer,
  name          text,
  album_id      integer,
  media_type_id integer,
  genre_id      integer,
  composer      text,
  milliseconds  integer,
  bytes         integer,
  unit_price    numeric(10,2)
);

CREATE TABLE core.invoice (
  invoice_id          integer,
  customer_id         integer,
  invoice_date        timestamp,
  billing_address     text,
  billing_city        text,
  billing_state       text,
  billing_country     text,
  billing_postal_code text,
  total               numeric(10,2)
);

CREATE TABLE core.invoiceline (
  invoice_line_id integer,
  invoice_id      integer,
  track_id        integer,
  unit_price      numeric(10,2),
  quantity        integer
);

CREATE TABLE core.playlist (
  playlist_id integer,
  name        text
);

CREATE TABLE core.playlisttrack (
  playlist_id integer,
  track_id    integer
);

COMMIT;
