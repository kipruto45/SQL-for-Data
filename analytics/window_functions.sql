-- Running revenue trend by month.
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::DATE AS month_start,
        SUM(CASE WHEN o.status = 'PAID' AND t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS monthly_revenue
    FROM oltp.orders o
    LEFT JOIN oltp.transactions t
        ON t.order_id = o.order_id
    GROUP BY DATE_TRUNC('month', o.order_date)::DATE
)
SELECT
    month_start,
    monthly_revenue,
    SUM(monthly_revenue) OVER (ORDER BY month_start) AS running_revenue,
    AVG(monthly_revenue) OVER (ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3_month_avg,
    LAG(monthly_revenue) OVER (ORDER BY month_start) AS previous_month_revenue
FROM monthly
ORDER BY month_start;

-- Customer ranking by lifetime spend.
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(CASE WHEN o.status = 'PAID' AND t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS spend,
    DENSE_RANK() OVER (
        ORDER BY SUM(CASE WHEN o.status = 'PAID' AND t.status = 'SUCCESS' THEN t.amount ELSE 0 END) DESC
    ) AS spend_rank
FROM oltp.customers c
LEFT JOIN oltp.orders o ON o.customer_id = c.customer_id
LEFT JOIN oltp.transactions t ON t.order_id = o.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY spend_rank, customer_id;
