-- Load core from staging (clean + constrained)

TRUNCATE core.playlisttrack,
         core.playlist,
         core.invoiceline,
         core.invoice,
         core.track,
         core.album,
         core.artist,
         core.customer,
         core.employee,
         core.genre,
         core.mediatype
CASCADE;

-- Dimensions first
INSERT INTO core.employee (
  employee_id, last_name, first_name, title, reports_to, birth_date, hire_date,
  address, city, state, country, postal_code, phone, fax, email
)
SELECT
  employeeid,
  TRIM(lastname),
  TRIM(firstname),
  NULLIF(TRIM(title), ''),
  reportsto,
  birthdate,
  hiredate,
  NULLIF(TRIM(address), ''),
  NULLIF(TRIM(city), ''),
  NULLIF(TRIM(state), ''),
  NULLIF(TRIM(country), ''),
  NULLIF(TRIM(postalcode), ''),
  NULLIF(TRIM(phone), ''),
  NULLIF(TRIM(fax), ''),
  NULLIF(TRIM(email), '')
FROM stg.employee;

INSERT INTO core.customer (
  customer_id, first_name, last_name, company, address, city, state, country,
  postal_code, phone, fax, email, support_rep_id
)
SELECT
  customerid,
  TRIM(firstname),
  TRIM(lastname),
  NULLIF(TRIM(company), ''),
  NULLIF(TRIM(address), ''),
  NULLIF(TRIM(city), ''),
  NULLIF(TRIM(state), ''),
  NULLIF(TRIM(country), ''),
  NULLIF(TRIM(postalcode), ''),
  NULLIF(TRIM(phone), ''),
  NULLIF(TRIM(fax), ''),
  NULLIF(TRIM(email), ''),
  supportrepid
FROM stg.customer;

INSERT INTO core.artist (artist_id, name)
SELECT artistid, NULLIF(TRIM(name), '')
FROM stg.artist;

INSERT INTO core.album (album_id, title, artist_id)
SELECT albumid, TRIM(title), artistid
FROM stg.album;

INSERT INTO core.genre (genre_id, name)
SELECT genreid, NULLIF(TRIM(name), '')
FROM stg.genre;

INSERT INTO core.mediatype (media_type_id, name)
SELECT mediatypeid, NULLIF(TRIM(name), '')
FROM stg.mediatype;

INSERT INTO core.track (
  track_id, name, album_id, media_type_id, genre_id, composer,
  milliseconds, bytes, unit_price
)
SELECT
  trackid,
  TRIM(name),
  albumid,
  mediatypeid,
  genreid,
  NULLIF(TRIM(composer), ''),
  milliseconds,
  bytes,
  unitprice
FROM stg.track;

-- Facts after dimensions
INSERT INTO core.invoice (
  invoice_id, customer_id, invoice_date, billing_address, billing_city,
  billing_state, billing_country, billing_postal_code, total
)
SELECT
  invoiceid,
  customerid,
  invoicedate,
  NULLIF(TRIM(billingaddress), ''),
  NULLIF(TRIM(billingcity), ''),
  NULLIF(TRIM(billingstate), ''),
  NULLIF(TRIM(billingcountry), ''),
  NULLIF(TRIM(billingpostalcode), ''),
  total
FROM stg.invoice;

INSERT INTO core.invoiceline (
  invoice_line_id, invoice_id, track_id, unit_price, quantity
)
SELECT
  invoicelineid,
  invoiceid,
  trackid,
  unitprice,
  quantity
FROM stg.invoiceline;

-- Optional tables
INSERT INTO core.playlist (playlist_id, name)
SELECT playlistid, NULLIF(TRIM(name), '')
FROM stg.playlist;

INSERT INTO core.playlisttrack (playlist_id, track_id)
SELECT playlistid, trackid
FROM stg.playlisttrack;
