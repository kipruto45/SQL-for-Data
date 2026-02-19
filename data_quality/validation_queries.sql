-- Domain and business rule validations.
SELECT
    'negative_or_zero_transaction_amount' AS check_name,
    COUNT(*) AS failed_rows
FROM oltp.transactions
WHERE amount <= 0
UNION ALL
SELECT
    'orders_with_future_date',
    COUNT(*)
FROM oltp.orders
WHERE order_date > CURRENT_DATE
UNION ALL
SELECT
    'invalid_customer_email',
    COUNT(*)
FROM oltp.customers
WHERE email !~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'
UNION ALL
SELECT
    'invalid_country_code',
    COUNT(*)
FROM oltp.customers
WHERE country !~ '^[A-Z]{2}$';
