CREATE TABLE IF NOT EXISTS warehouse.fact_sales (
    sales_sk BIGSERIAL PRIMARY KEY,
    transaction_id BIGINT UNIQUE NOT NULL,
    order_id BIGINT NOT NULL,
    customer_sk BIGINT NOT NULL REFERENCES warehouse.dim_customer(customer_sk),
    date_sk INT NOT NULL REFERENCES warehouse.dim_date(date_sk),
    payment_method_sk INT REFERENCES warehouse.dim_payment_method(payment_method_sk),
    order_status VARCHAR(20) NOT NULL,
    transaction_status VARCHAR(20) NOT NULL,
    revenue_amount NUMERIC(12,2) NOT NULL,
    risk_score NUMERIC(5,2),
    load_ts TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fact_sales_date_sk ON warehouse.fact_sales(date_sk);
CREATE INDEX IF NOT EXISTS idx_fact_sales_customer_sk ON warehouse.fact_sales(customer_sk);
CREATE INDEX IF NOT EXISTS idx_fact_sales_status ON warehouse.fact_sales(transaction_status, order_status);
