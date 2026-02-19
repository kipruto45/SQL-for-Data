-- Example 1: avoid casting indexed column in predicate.
-- Less efficient:
EXPLAIN
SELECT *
FROM oltp.orders
WHERE DATE_TRUNC('day', order_date) = DATE '2026-01-05';

-- More efficient:
EXPLAIN
SELECT *
FROM oltp.orders
WHERE order_date >= DATE '2026-01-05'
  AND order_date < DATE '2026-01-06';

-- Example 2: aggregate once and join, instead of repeated correlated subqueries.
EXPLAIN
WITH paid_totals AS (
    SELECT
        o.customer_id,
        SUM(t.amount) AS total_paid
    FROM oltp.orders o
    JOIN oltp.transactions t ON t.order_id = o.order_id
    WHERE o.status = 'PAID' AND t.status = 'SUCCESS'
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COALESCE(p.total_paid, 0) AS total_paid
FROM oltp.customers c
LEFT JOIN paid_totals p ON p.customer_id = c.customer_id
ORDER BY total_paid DESC;
