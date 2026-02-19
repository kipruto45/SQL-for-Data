-- Raw landing tables (all text to simplify ingestion).
CREATE TABLE IF NOT EXISTS staging.customers_raw (
    customer_id TEXT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    phone TEXT,
    city TEXT,
    country TEXT,
    signup_date TEXT,
    updated_at TEXT
);

CREATE TABLE IF NOT EXISTS staging.orders_raw (
    order_id TEXT,
    customer_id TEXT,
    order_date TEXT,
    status TEXT,
    total_amount TEXT,
    currency TEXT,
    updated_at TEXT
);

CREATE TABLE IF NOT EXISTS staging.transactions_raw (
    transaction_id TEXT,
    order_id TEXT,
    transaction_date TEXT,
    payment_method TEXT,
    amount TEXT,
    status TEXT,
    risk_score TEXT,
    updated_at TEXT
);

-- Core OLTP tables.
CREATE TABLE IF NOT EXISTS oltp.customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    city VARCHAR(100),
    country VARCHAR(2) NOT NULL,
    signup_date DATE NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS oltp.orders (
    order_id BIGINT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES oltp.customers(customer_id),
    order_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS oltp.transactions (
    transaction_id BIGINT PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES oltp.orders(order_id),
    transaction_date TIMESTAMPTZ NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    risk_score NUMERIC(5,2),
    updated_at TIMESTAMPTZ NOT NULL
);

-- Metadata for incremental loads.
CREATE TABLE IF NOT EXISTS metadata.etl_watermark (
    pipeline_name TEXT PRIMARY KEY,
    last_success_ts TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ '1970-01-01 00:00:00+00'
);

-- Monitoring tables.
CREATE TABLE IF NOT EXISTS monitoring.row_count_history (
    table_name TEXT NOT NULL,
    snapshot_date DATE NOT NULL,
    row_count BIGINT NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (table_name, snapshot_date)
);

CREATE TABLE IF NOT EXISTS monitoring.data_quality_results (
    check_name TEXT NOT NULL,
    check_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    failed_rows BIGINT NOT NULL,
    severity TEXT NOT NULL,
    details TEXT
);
