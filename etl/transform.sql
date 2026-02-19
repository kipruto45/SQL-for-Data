-- Standardize typing, normalize values, and deduplicate by latest update.
CREATE OR REPLACE VIEW staging.customers_clean AS
WITH typed AS (
    SELECT
        customer_id::INT AS customer_id,
        INITCAP(TRIM(first_name)) AS first_name,
        INITCAP(TRIM(last_name)) AS last_name,
        LOWER(TRIM(email)) AS email,
        NULLIF(TRIM(phone), '') AS phone,
        INITCAP(TRIM(city)) AS city,
        UPPER(TRIM(country)) AS country,
        signup_date::DATE AS signup_date,
        updated_at::TIMESTAMPTZ AS updated_at
    FROM staging.customers_raw
    WHERE customer_id ~ '^[0-9]+$'
), filtered AS (
    SELECT *
    FROM typed
    WHERE email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'
      AND country ~ '^[A-Z]{2}$'
), deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY updated_at DESC) AS rn
    FROM filtered
)
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    country,
    signup_date,
    updated_at
FROM deduped
WHERE rn = 1;

CREATE OR REPLACE VIEW staging.orders_clean AS
WITH typed AS (
    SELECT
        order_id::BIGINT AS order_id,
        customer_id::INT AS customer_id,
        order_date::DATE AS order_date,
        UPPER(TRIM(status)) AS status,
        total_amount::NUMERIC(12,2) AS total_amount,
        UPPER(TRIM(currency)) AS currency,
        updated_at::TIMESTAMPTZ AS updated_at
    FROM staging.orders_raw
    WHERE order_id ~ '^[0-9]+$'
      AND customer_id ~ '^[0-9]+$'
), filtered AS (
    SELECT *
    FROM typed
    WHERE status IN ('PENDING', 'PAID', 'CANCELLED', 'REFUNDED')
      AND total_amount >= 0
      AND currency ~ '^[A-Z]{3}$'
), deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY updated_at DESC) AS rn
    FROM filtered
)
SELECT
    order_id,
    customer_id,
    order_date,
    status,
    total_amount,
    currency,
    updated_at
FROM deduped
WHERE rn = 1;

CREATE OR REPLACE VIEW staging.transactions_clean AS
WITH typed AS (
    SELECT
        transaction_id::BIGINT AS transaction_id,
        order_id::BIGINT AS order_id,
        transaction_date::TIMESTAMPTZ AS transaction_date,
        UPPER(TRIM(payment_method)) AS payment_method,
        amount::NUMERIC(12,2) AS amount,
        UPPER(TRIM(status)) AS status,
        risk_score::NUMERIC(5,2) AS risk_score,
        updated_at::TIMESTAMPTZ AS updated_at
    FROM staging.transactions_raw
    WHERE transaction_id ~ '^[0-9]+$'
      AND order_id ~ '^[0-9]+$'
), filtered AS (
    SELECT *
    FROM typed
    WHERE payment_method IN ('CARD', 'BANK_TRANSFER', 'WALLET')
      AND status IN ('SUCCESS', 'FAILED', 'CHARGEBACK', 'REFUNDED')
      AND amount >= 0
      AND (risk_score BETWEEN 0 AND 100 OR risk_score IS NULL)
), deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY updated_at DESC) AS rn
    FROM filtered
)
SELECT
    transaction_id,
    order_id,
    transaction_date,
    payment_method,
    amount,
    status,
    risk_score,
    updated_at
FROM deduped
WHERE rn = 1;
