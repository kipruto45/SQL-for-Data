EXPLAIN ANALYZE
SELECT
    o.customer_id,
    DATE_TRUNC('month', o.order_date) AS month_start,
    SUM(CASE WHEN t.status = 'SUCCESS' AND o.status = 'PAID' THEN t.amount ELSE 0 END) AS revenue
FROM oltp.orders o
LEFT JOIN oltp.transactions t ON t.order_id = o.order_id
GROUP BY o.customer_id, DATE_TRUNC('month', o.order_date)
ORDER BY month_start;

EXPLAIN ANALYZE
SELECT
    c.customer_id,
    COUNT(*) AS chargebacks
FROM oltp.customers c
JOIN oltp.orders o ON o.customer_id = c.customer_id
JOIN oltp.transactions t ON t.order_id = o.order_id
WHERE t.status = 'CHARGEBACK'
GROUP BY c.customer_id;
