#!/usr/bin/env bash
set -euo pipefail

CONTAINER="chinookanalytics-db"
DB="chinook"
USER="chinook"
SQL_DIR="/work/sql"

echo "========================================"
echo "ChinookAnalytics - Full SQL Pipeline"
echo "========================================"

run_sql () {
    FILE="$1"
    echo ""
    echo "Running ${FILE} ..."
    docker exec -i "${CONTAINER}" \
        psql -U "${USER}" -d "${DB}" -f "${SQL_DIR}/${FILE}"
}

echo ""
echo "==== STG Layer ===="
run_sql 01_create_schemas.sql
run_sql 02_create_stg_tables.sql
run_sql 03_load_stg.sql
run_sql 04_eda_stg_structural.sql

echo ""
echo "==== CORE Layer ===="
run_sql 05_create_core_tables.sql
run_sql 06_add_core_constraints.sql
run_sql 07_load_core.sql
run_sql 08_data_profiling.sql

echo ""
echo "==== MARTS Layer ===="
run_sql 09_create_marts_tables.sql
run_sql 10_add_marts_constraints.sql
run_sql 11_load_marts.sql
run_sql 12_validate_marts.sql

echo ""
echo "========================================"
echo "Pipeline completed successfully."
echo "========================================"
