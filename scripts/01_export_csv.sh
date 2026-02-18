#!/usr/bin/env bash
set -euo pipefail

SQLITE_FILE="data/raw/Chinook_Sqlite.sqlite"
OUT_DIR="data/raw/csv"

echo "Creating CSV output directory..."
mkdir -p "${OUT_DIR}"

echo "Listing tables from SQLite..."
TABLES=$(sqlite3 "${SQLITE_FILE}" "
SELECT name
FROM sqlite_master
WHERE type='table'
ORDER BY name;
")

for TABLE in ${TABLES}; do
    echo "Exporting ${TABLE}..."

    sqlite3 "${SQLITE_FILE}" <<SQL
.headers on
.mode csv
.output ${OUT_DIR}/${TABLE}.csv
SELECT * FROM "${TABLE}";
.output stdout
SQL

done

echo "Export completed."
ls -1 "${OUT_DIR}"

