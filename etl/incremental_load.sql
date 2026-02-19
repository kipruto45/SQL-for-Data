-- Incremental pattern based on per-entity watermark timestamps.
INSERT INTO metadata.etl_watermark (pipeline_name)
VALUES ('customers'), ('orders'), ('transactions')
ON CONFLICT (pipeline_name) DO NOTHING;

WITH last_mark AS (
    SELECT last_success_ts FROM metadata.etl_watermark WHERE pipeline_name = 'customers'
), changed AS (
    SELECT c.*
    FROM staging.customers_clean c
    CROSS JOIN last_mark m
    WHERE c.updated_at > m.last_success_ts
)
INSERT INTO oltp.customers (
    customer_id, first_name, last_name, email, phone, city, country, signup_date, updated_at
)
SELECT customer_id, first_name, last_name, email, phone, city, country, signup_date, updated_at
FROM changed
ON CONFLICT (customer_id) DO UPDATE
SET
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    email = EXCLUDED.email,
    phone = EXCLUDED.phone,
    city = EXCLUDED.city,
    country = EXCLUDED.country,
    signup_date = EXCLUDED.signup_date,
    updated_at = EXCLUDED.updated_at;

UPDATE metadata.etl_watermark
SET last_success_ts = COALESCE((SELECT MAX(updated_at) FROM staging.customers_clean), last_success_ts)
WHERE pipeline_name = 'customers';

WITH last_mark AS (
    SELECT last_success_ts FROM metadata.etl_watermark WHERE pipeline_name = 'orders'
), changed AS (
    SELECT o.*
    FROM staging.orders_clean o
    CROSS JOIN last_mark m
    WHERE o.updated_at > m.last_success_ts
)
INSERT INTO oltp.orders (
    order_id, customer_id, order_date, status, total_amount, currency, updated_at
)
SELECT
    c.order_id,
    c.customer_id,
    c.order_date,
    c.status,
    c.total_amount,
    c.currency,
    c.updated_at
FROM changed c
JOIN oltp.customers cu ON cu.customer_id = c.customer_id
ON CONFLICT (order_id) DO UPDATE
SET
    customer_id = EXCLUDED.customer_id,
    order_date = EXCLUDED.order_date,
    status = EXCLUDED.status,
    total_amount = EXCLUDED.total_amount,
    currency = EXCLUDED.currency,
    updated_at = EXCLUDED.updated_at;

UPDATE metadata.etl_watermark
SET last_success_ts = COALESCE((SELECT MAX(updated_at) FROM staging.orders_clean), last_success_ts)
WHERE pipeline_name = 'orders';

WITH last_mark AS (
    SELECT last_success_ts FROM metadata.etl_watermark WHERE pipeline_name = 'transactions'
), changed AS (
    SELECT t.*
    FROM staging.transactions_clean t
    CROSS JOIN last_mark m
    WHERE t.updated_at > m.last_success_ts
)
INSERT INTO oltp.transactions (
    transaction_id, order_id, transaction_date, payment_method, amount, status, risk_score, updated_at
)
SELECT
    c.transaction_id,
    c.order_id,
    c.transaction_date,
    c.payment_method,
    c.amount,
    c.status,
    c.risk_score,
    c.updated_at
FROM changed c
JOIN oltp.orders o ON o.order_id = c.order_id
ON CONFLICT (transaction_id) DO UPDATE
SET
    order_id = EXCLUDED.order_id,
    transaction_date = EXCLUDED.transaction_date,
    payment_method = EXCLUDED.payment_method,
    amount = EXCLUDED.amount,
    status = EXCLUDED.status,
    risk_score = EXCLUDED.risk_score,
    updated_at = EXCLUDED.updated_at;

UPDATE metadata.etl_watermark
SET last_success_ts = COALESCE((SELECT MAX(updated_at) FROM staging.transactions_clean), last_success_ts)
WHERE pipeline_name = 'transactions';
