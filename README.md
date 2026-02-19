# SQL Data Engineering Project

End-to-end SQL project for ingesting raw CSV data, transforming it into an OLTP model, loading a dimensional warehouse, and running analytics, quality checks, performance tests, and monitoring.

## Project Layout

```text
sql-data-engineering-project/
├── database/
├── data/
├── etl/
├── warehouse/
├── analytics/
├── data_quality/
├── performance/
├── monitoring/
├── tests/
└── docs/
```

## Tech Stack

- PostgreSQL 14+
- SQL (psql-compatible scripts)
- Optional Python tools (linting/automation)

## CI

- GitHub Actions workflow: `.github/workflows/ci.yml`
- Runs the full pipeline (`./run_all.sh`) on pushes and pull requests to `main`.

## Quick Start

One command end-to-end (recommended):

```bash
chmod +x run_all.sh
./run_all.sh
```

Run with Docker (PostgreSQL + pipeline):

```bash
docker compose up -d postgres
docker compose --profile run run --rm pipeline
```

Manual execution:

1. Create database (example):

```bash
createdb sql_data_engineering
```

2. Set environment values in `.env`.

3. Initialize core schemas and tables:

```bash
psql "$DATABASE_URL" -f database/schema.sql
psql "$DATABASE_URL" -f database/tables.sql
psql "$DATABASE_URL" -f database/constraints.sql
psql "$DATABASE_URL" -f database/indexes.sql
```

4. Load source data and run ETL:

```bash
psql "$DATABASE_URL" -f etl/extract.sql
psql "$DATABASE_URL" -f etl/transform.sql
psql "$DATABASE_URL" -f etl/load.sql
```

5. Build warehouse model (includes SCD Type 2 update + fact load):

```bash
psql "$DATABASE_URL" -f warehouse/star_schema.sql
```

6. Run quality checks, analytics, and tests:

```bash
psql "$DATABASE_URL" -f data_quality/validation_queries.sql
psql "$DATABASE_URL" -f analytics/revenue_analysis.sql
psql "$DATABASE_URL" -f tests/test_data_load.sql
psql "$DATABASE_URL" -f tests/test_scd_logic.sql
psql "$DATABASE_URL" -f tests/test_quality_checks.sql
psql "$DATABASE_URL" -f tests/test_customer_segmentation.sql
```

## Pipeline Flow

1. **Extract** CSVs into staging raw tables.
2. **Transform** and standardize datatypes + deduplicate records.
3. **Load** cleaned data into OLTP tables with upserts.
4. **Warehouse** load dimensions/facts and apply SCD Type 2 for customers.
5. **Analyze** KPIs and run fraud/retention/segmentation logic.
6. **Monitor** row counts and anomaly signals.

## Notes

- SQL is written for PostgreSQL.
- `etl/extract.sql` uses `\copy`, so run with `psql` from project root.
- Example data is included in `data/raw/`.
- Architecture and data model diagrams are generated from DOT sources:
  - `docs/architecture_diagram.dot`
  - `docs/data_model.dot`
  - Regenerate with `./docs/generate_diagrams.sh`
