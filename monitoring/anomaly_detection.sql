-- Revenue anomaly detection using z-score over daily paid revenue.
WITH daily_revenue AS (
    SELECT
        o.order_date AS day,
        SUM(CASE WHEN o.status = 'PAID' AND t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS revenue
    FROM oltp.orders o
    LEFT JOIN oltp.transactions t ON t.order_id = o.order_id
    GROUP BY o.order_date
), stats AS (
    SELECT
        day,
        revenue,
        AVG(revenue) OVER () AS avg_revenue,
        STDDEV_SAMP(revenue) OVER () AS std_revenue
    FROM daily_revenue
)
SELECT
    day,
    revenue,
    avg_revenue,
    std_revenue,
    ROUND((revenue - avg_revenue) / NULLIF(std_revenue, 0), 2) AS z_score
FROM stats
WHERE ABS((revenue - avg_revenue) / NULLIF(std_revenue, 0)) >= 2.0
ORDER BY day;
