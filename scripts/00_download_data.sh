#!/usr/bin/env bash
set -euo pipefail

RAW_DIR="data/raw"
SQLITE_FILE="${RAW_DIR}/Chinook_Sqlite.sqlite"
SQLITE_URL="https://github.com/lerocha/chinook-database/raw/master/ChinookDatabase/DataSources/Chinook_Sqlite.sqlite"

mkdir -p "${RAW_DIR}"

echo "Downloading raw SQLite..."
curl -L --fail -o "${SQLITE_FILE}" "${SQLITE_URL}"

echo "Raw ready: ${SQLITE_FILE}"
