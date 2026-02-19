-- Load curated data into OLTP tables with upserts.
INSERT INTO oltp.customers (
    customer_id, first_name, last_name, email, phone, city, country, signup_date, updated_at
)
SELECT
    customer_id, first_name, last_name, email, phone, city, country, signup_date, updated_at
FROM staging.customers_clean
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

INSERT INTO oltp.orders (
    order_id, customer_id, order_date, status, total_amount, currency, updated_at
)
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    o.total_amount,
    o.currency,
    o.updated_at
FROM staging.orders_clean o
JOIN oltp.customers c
    ON c.customer_id = o.customer_id
ON CONFLICT (order_id) DO UPDATE
SET
    customer_id = EXCLUDED.customer_id,
    order_date = EXCLUDED.order_date,
    status = EXCLUDED.status,
    total_amount = EXCLUDED.total_amount,
    currency = EXCLUDED.currency,
    updated_at = EXCLUDED.updated_at;

INSERT INTO oltp.transactions (
    transaction_id, order_id, transaction_date, payment_method, amount, status, risk_score, updated_at
)
SELECT
    t.transaction_id,
    t.order_id,
    t.transaction_date,
    t.payment_method,
    t.amount,
    t.status,
    t.risk_score,
    t.updated_at
FROM staging.transactions_clean t
JOIN oltp.orders o
    ON o.order_id = t.order_id
ON CONFLICT (transaction_id) DO UPDATE
SET
    order_id = EXCLUDED.order_id,
    transaction_date = EXCLUDED.transaction_date,
    payment_method = EXCLUDED.payment_method,
    amount = EXCLUDED.amount,
    status = EXCLUDED.status,
    risk_score = EXCLUDED.risk_score,
    updated_at = EXCLUDED.updated_at;
