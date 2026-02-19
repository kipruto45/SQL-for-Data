-- SCD Type 2 maintenance for customer dimension.
WITH source_data AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.city,
        c.country,
        c.signup_date,
        MD5(CONCAT_WS('|', c.first_name, c.last_name, c.email, COALESCE(c.city, ''), c.country, c.signup_date::TEXT)) AS hash_diff
    FROM oltp.customers c
), changed_current AS (
    SELECT
        d.customer_sk
    FROM warehouse.dim_customer d
    JOIN source_data s
        ON s.customer_id = d.customer_id
    WHERE d.is_current = TRUE
      AND d.hash_diff <> s.hash_diff
)
UPDATE warehouse.dim_customer d
SET
    valid_to = CURRENT_DATE - 1,
    is_current = FALSE
FROM changed_current cc
WHERE d.customer_sk = cc.customer_sk;

WITH source_data AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.city,
        c.country,
        c.signup_date,
        MD5(CONCAT_WS('|', c.first_name, c.last_name, c.email, COALESCE(c.city, ''), c.country, c.signup_date::TEXT)) AS hash_diff
    FROM oltp.customers c
)
INSERT INTO warehouse.dim_customer (
    customer_id,
    first_name,
    last_name,
    email,
    city,
    country,
    signup_date,
    valid_from,
    valid_to,
    is_current,
    hash_diff
)
SELECT
    s.customer_id,
    s.first_name,
    s.last_name,
    s.email,
    s.city,
    s.country,
    s.signup_date,
    CURRENT_DATE,
    DATE '9999-12-31',
    TRUE,
    s.hash_diff
FROM source_data s
LEFT JOIN warehouse.dim_customer d
    ON d.customer_id = s.customer_id
   AND d.is_current = TRUE
WHERE d.customer_id IS NULL
   OR d.hash_diff <> s.hash_diff;
