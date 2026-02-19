-- Build warehouse dimensions and fact tables.
\i warehouse/dimension_tables.sql
\i warehouse/fact_tables.sql

-- Fill date dimension for a standard reporting window.
INSERT INTO warehouse.dim_date (
    date_sk,
    full_date,
    day_number,
    month_number,
    month_name,
    quarter_number,
    year_number,
    is_weekend
)
SELECT
    TO_CHAR(d::DATE, 'YYYYMMDD')::INT AS date_sk,
    d::DATE,
    EXTRACT(DAY FROM d)::INT,
    EXTRACT(MONTH FROM d)::INT,
    TO_CHAR(d::DATE, 'Mon'),
    EXTRACT(QUARTER FROM d)::INT,
    EXTRACT(YEAR FROM d)::INT,
    (EXTRACT(ISODOW FROM d) IN (6, 7)) AS is_weekend
FROM GENERATE_SERIES(DATE '2024-01-01', DATE '2030-12-31', INTERVAL '1 day') AS gs(d)
ON CONFLICT (date_sk) DO NOTHING;

INSERT INTO warehouse.dim_payment_method (payment_method)
SELECT DISTINCT payment_method
FROM oltp.transactions
ON CONFLICT (payment_method) DO NOTHING;

-- Apply customer SCD2 before loading facts.
\i warehouse/scd_type2.sql

-- Initial fact load (rerunnable with upsert semantics).
INSERT INTO warehouse.fact_sales (
    transaction_id,
    order_id,
    customer_sk,
    date_sk,
    payment_method_sk,
    order_status,
    transaction_status,
    revenue_amount,
    risk_score
)
SELECT
    t.transaction_id,
    o.order_id,
    dc.customer_sk,
    TO_CHAR(o.order_date, 'YYYYMMDD')::INT AS date_sk,
    pm.payment_method_sk,
    o.status,
    t.status,
    CASE
        WHEN t.status = 'SUCCESS' AND o.status = 'PAID' THEN t.amount
        ELSE 0
    END AS revenue_amount,
    t.risk_score
FROM oltp.transactions t
JOIN oltp.orders o
    ON o.order_id = t.order_id
JOIN warehouse.dim_customer dc
    ON dc.customer_id = o.customer_id
   AND dc.is_current = TRUE
LEFT JOIN warehouse.dim_payment_method pm
    ON pm.payment_method = t.payment_method
ON CONFLICT (transaction_id) DO UPDATE
SET
    order_id = EXCLUDED.order_id,
    customer_sk = EXCLUDED.customer_sk,
    date_sk = EXCLUDED.date_sk,
    payment_method_sk = EXCLUDED.payment_method_sk,
    order_status = EXCLUDED.order_status,
    transaction_status = EXCLUDED.transaction_status,
    revenue_amount = EXCLUDED.revenue_amount,
    risk_score = EXCLUDED.risk_score,
    load_ts = NOW();
