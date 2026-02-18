-- Staging tables (raw CSV mirror)

DROP TABLE IF EXISTS stg.album;
CREATE TABLE stg.album (
  albumid  integer,
  title    text,
  artistid integer
);

DROP TABLE IF EXISTS stg.artist;
CREATE TABLE stg.artist (
  artistid integer,
  name     text
);

DROP TABLE IF EXISTS stg.customer;
CREATE TABLE stg.customer (
  customerid   integer,
  firstname    text,
  lastname     text,
  company      text,
  address      text,
  city         text,
  state        text,
  country      text,
  postalcode   text,
  phone        text,
  fax          text,
  email        text,
  supportrepid integer
);

DROP TABLE IF EXISTS stg.employee;
CREATE TABLE stg.employee (
  employeeid integer,
  lastname   text,
  firstname  text,
  title      text,
  reportsto  integer,
  birthdate  timestamp,
  hiredate   timestamp,
  address    text,
  city       text,
  state      text,
  country    text,
  postalcode text,
  phone      text,
  fax        text,
  email      text
);

DROP TABLE IF EXISTS stg.genre;
CREATE TABLE stg.genre (
  genreid integer,
  name    text
);

DROP TABLE IF EXISTS stg.invoiceline;
CREATE TABLE stg.invoiceline (
  invoicelineid integer,
  invoiceid     integer,
  trackid       integer,
  unitprice     numeric(10,2),
  quantity      integer
);

DROP TABLE IF EXISTS stg.invoice;
CREATE TABLE stg.invoice (
  invoiceid         integer,
  customerid        integer,
  invoicedate       timestamp,
  billingaddress    text,
  billingcity       text,
  billingstate      text,
  billingcountry    text,
  billingpostalcode text,
  total             numeric(10,2)
);

DROP TABLE IF EXISTS stg.mediatype;
CREATE TABLE stg.mediatype (
  mediatypeid integer,
  name        text
);

DROP TABLE IF EXISTS stg.playlist;
CREATE TABLE stg.playlist (
  playlistid integer,
  name       text
);

DROP TABLE IF EXISTS stg.playlisttrack;
CREATE TABLE stg.playlisttrack (
  playlistid integer,
  trackid    integer
);

DROP TABLE IF EXISTS stg.track;
CREATE TABLE stg.track (
  trackid      integer,
  name         text,
  albumid      integer,
  mediatypeid  integer,
  genreid      integer,
  composer     text,
  milliseconds integer,
  bytes        integer,
  unitprice    numeric(10,2)
);

