-- Check duplicate business keys in OLTP model.
SELECT
    'customers' AS table_name,
    customer_id::TEXT AS duplicate_key,
    COUNT(*) AS duplicate_count
FROM oltp.customers
GROUP BY customer_id
HAVING COUNT(*) > 1
UNION ALL
SELECT
    'orders',
    order_id::TEXT,
    COUNT(*)
FROM oltp.orders
GROUP BY order_id
HAVING COUNT(*) > 1
UNION ALL
SELECT
    'transactions',
    transaction_id::TEXT,
    COUNT(*)
FROM oltp.transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;
