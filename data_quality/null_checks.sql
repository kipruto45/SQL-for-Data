-- Count NULL critical fields in core tables.
SELECT 'oltp.customers.customer_id' AS column_name, COUNT(*) AS null_count
FROM oltp.customers
WHERE customer_id IS NULL
UNION ALL
SELECT 'oltp.customers.email', COUNT(*)
FROM oltp.customers
WHERE email IS NULL
UNION ALL
SELECT 'oltp.orders.order_id', COUNT(*)
FROM oltp.orders
WHERE order_id IS NULL
UNION ALL
SELECT 'oltp.orders.customer_id', COUNT(*)
FROM oltp.orders
WHERE customer_id IS NULL
UNION ALL
SELECT 'oltp.transactions.transaction_id', COUNT(*)
FROM oltp.transactions
WHERE transaction_id IS NULL
UNION ALL
SELECT 'oltp.transactions.order_id', COUNT(*)
FROM oltp.transactions
WHERE order_id IS NULL;
