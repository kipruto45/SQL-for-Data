#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

load_env_file() {
  local env_file="$1"
  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" != *=* ]] && continue

    local key="${line%%=*}"
    local value="${line#*=}"
    key="${key//[[:space:]]/}"

    if [[ -z "$key" ]]; then
      continue
    fi

    # Keep externally provided values (useful for Docker/CI overrides).
    if [[ -z "${!key+x}" ]]; then
      export "$key=$value"
    fi
  done < "$env_file"
}

if [[ -f ".env" ]]; then
  load_env_file ".env"
else
  echo "No .env found. Using environment variables only."
fi

if [[ -z "${DATABASE_URL:-}" ]]; then
  if [[ -n "${DB_HOST:-}" && -n "${DB_PORT:-}" && -n "${DB_NAME:-}" && -n "${DB_USER:-}" && -n "${DB_PASSWORD:-}" ]]; then
    export DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
  else
    echo "DATABASE_URL is not set. Provide it directly or via DB_* variables."
    exit 1
  fi
fi

export PGPASSWORD="${DB_PASSWORD:-${PGPASSWORD:-}}"

ADMIN_URL="postgresql://${DB_USER:-postgres}:${DB_PASSWORD:-postgres}@${DB_HOST:-localhost}:${DB_PORT:-5432}/postgres"
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
run_sql "tests/test_customer_segmentation.sql"

echo "Pipeline completed successfully."
