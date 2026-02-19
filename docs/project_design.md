# Project Design

## Objective

Build a modular SQL-first data engineering project that demonstrates ingestion, cleansing, OLTP loading, dimensional modeling, analytics, data quality checks, performance tuning, and monitoring.

## Architecture

1. **Source Layer**
- CSV files in `data/raw/`.

2. **Staging Layer (`staging`)**
- Raw landing tables preserve source shape.
- Transform views enforce types, cleanup, and deduplication.

3. **Core OLTP Layer (`oltp`)**
- `customers`, `orders`, `transactions`.
- Constraints + indexes enforce consistency and support query performance.

4. **Warehouse Layer (`warehouse`)**
- Star schema with dimensions (`dim_customer`, `dim_date`, `dim_payment_method`) and fact table (`fact_sales`).
- Customer dimension uses SCD Type 2.

5. **Consumption Layer**
- Analytics queries for revenue, segmentation, fraud, retention, and window-function reporting.
- Data quality and tests validate correctness.
- Monitoring scripts track row counts and anomalies.

Diagram assets are maintained as source files in:
- `docs/architecture_diagram.dot`
- `docs/data_model.dot`

Regenerate PNG outputs with:
- `./docs/generate_diagrams.sh`

## Data Model Highlights

- `orders.customer_id -> customers.customer_id`
- `transactions.order_id -> orders.order_id`
- `fact_sales` references surrogate keys from dimensions.
- Revenue recognized when `orders.status='PAID'` and `transactions.status='SUCCESS'`.

## Incremental Strategy

- `metadata.etl_watermark` stores per-pipeline last successful timestamp.
- Incremental ETL selects only staged rows with `updated_at > watermark`.
- Upsert logic handles inserts and updates safely.

## Quality Strategy

- Proactive checks: nulls, duplicates, referential integrity, domain validations.
- Assertive tests in `tests/` raise exceptions when thresholds/rules fail.
- Monitoring captures trend drift and outliers.
