-- Load raw CSV into staging
TRUNCATE stg.album, stg.artist, stg.customer, stg.employee, stg.genre,
         stg.invoice, stg.invoiceline, stg.mediatype, stg.playlist,
         stg.playlisttrack, stg.track;

COPY stg.album FROM '/work/data/raw/csv/Album.csv' WITH (FORMAT csv, HEADER true);
COPY stg.artist FROM '/work/data/raw/csv/Artist.csv' WITH (FORMAT csv, HEADER true);
COPY stg.customer FROM '/work/data/raw/csv/Customer.csv' WITH (FORMAT csv, HEADER true);
COPY stg.employee FROM '/work/data/raw/csv/Employee.csv' WITH (FORMAT csv, HEADER true);
COPY stg.genre FROM '/work/data/raw/csv/Genre.csv' WITH (FORMAT csv, HEADER true);
COPY stg.invoice FROM '/work/data/raw/csv/Invoice.csv' WITH (FORMAT csv, HEADER true);
COPY stg.invoiceline FROM '/work/data/raw/csv/InvoiceLine.csv' WITH (FORMAT csv, HEADER true);
COPY stg.mediatype FROM '/work/data/raw/csv/MediaType.csv' WITH (FORMAT csv, HEADER true);
COPY stg.playlist FROM '/work/data/raw/csv/Playlist.csv' WITH (FORMAT csv, HEADER true);
COPY stg.playlisttrack FROM '/work/data/raw/csv/PlaylistTrack.csv' WITH (FORMAT csv, HEADER true);
COPY stg.track FROM '/work/data/raw/csv/Track.csv' WITH (FORMAT csv, HEADER true);

