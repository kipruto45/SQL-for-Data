-- Detect orphaned records across relationships.
SELECT
    'orders_without_customer' AS issue_type,
    o.order_id::TEXT AS entity_id
FROM oltp.orders o
LEFT JOIN oltp.customers c
    ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT
    'transactions_without_order' AS issue_type,
    t.transaction_id::TEXT AS entity_id
FROM oltp.transactions t
LEFT JOIN oltp.orders o
    ON o.order_id = t.order_id
WHERE o.order_id IS NULL;
