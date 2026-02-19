-- Monthly revenue, order volume, and average order value.
SELECT
    DATE_TRUNC('month', o.order_date)::DATE AS month_start,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(CASE WHEN t.status = 'SUCCESS' AND o.status = 'PAID' THEN t.amount ELSE 0 END) AS revenue,
    ROUND(
        SUM(CASE WHEN t.status = 'SUCCESS' AND o.status = 'PAID' THEN t.amount ELSE 0 END)
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS avg_order_value
FROM oltp.orders o
LEFT JOIN oltp.transactions t
    ON t.order_id = o.order_id
GROUP BY DATE_TRUNC('month', o.order_date)::DATE
ORDER BY month_start;

-- Top customers by paid revenue.
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(CASE WHEN t.status = 'SUCCESS' AND o.status = 'PAID' THEN t.amount ELSE 0 END) AS lifetime_revenue
FROM oltp.customers c
JOIN oltp.orders o
    ON o.customer_id = c.customer_id
LEFT JOIN oltp.transactions t
    ON t.order_id = o.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY lifetime_revenue DESC;
