#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [[ ! -f ".env" ]]; then
  echo "Missing .env in $ROOT_DIR"
  exit 1
fi

set -a
source .env
set +a

if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "DATABASE_URL is not set in .env"
  exit 1
fi

export PGPASSWORD="${DB_PASSWORD:-}"

ADMIN_URL="postgresql://${DB_USER:-postgres}:${DB_PASSWORD:-}@${DB_HOST:-localhost}:${DB_PORT:-5432}/postgres"
TARGET_DB="${DB_NAME:-sql_data_engineering}"

echo "Checking target database: $TARGET_DB"
DB_EXISTS="$(psql "$ADMIN_URL" -tAc "SELECT 1 FROM pg_database WHERE datname='${TARGET_DB}'" || true)"
if [[ "$DB_EXISTS" != "1" ]]; then
  echo "Creating database: $TARGET_DB"
  psql "$ADMIN_URL" -v ON_ERROR_STOP=1 -c "CREATE DATABASE ${TARGET_DB};"
fi

run_sql() {
  local file="$1"
  echo "Running $file"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$file"
}

run_sql "database/schema.sql"
run_sql "database/tables.sql"
run_sql "database/constraints.sql"
run_sql "database/indexes.sql"

run_sql "etl/extract.sql"
run_sql "etl/transform.sql"
run_sql "etl/load.sql"
run_sql "etl/incremental_load.sql"

run_sql "warehouse/star_schema.sql"

run_sql "data_quality/null_checks.sql"
run_sql "data_quality/duplicate_checks.sql"
run_sql "data_quality/referential_integrity.sql"
run_sql "data_quality/validation_queries.sql"

run_sql "monitoring/row_count_checks.sql"
run_sql "monitoring/anomaly_detection.sql"

run_sql "analytics/revenue_analysis.sql"
run_sql "analytics/customer_segmentation.sql"
run_sql "analytics/fraud_detection.sql"
run_sql "analytics/retention_analysis.sql"
run_sql "analytics/window_functions.sql"

run_sql "performance/explain_queries.sql"
run_sql "performance/indexing_tests.sql"
run_sql "performance/optimization_examples.sql"

run_sql "tests/test_data_load.sql"
run_sql "tests/test_scd_logic.sql"
run_sql "tests/test_quality_checks.sql"

echo "Pipeline completed successfully."
