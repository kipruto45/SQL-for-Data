-- RFM-based segmentation using quartiles.
WITH rfm_base AS (
    SELECT
        c.customer_id,
        MAX(o.order_date) AS last_order_date,
        COUNT(DISTINCT o.order_id) FILTER (WHERE o.status = 'PAID') AS frequency,
        COALESCE(SUM(t.amount) FILTER (WHERE o.status = 'PAID' AND t.status = 'SUCCESS'), 0) AS monetary
    FROM oltp.customers c
    LEFT JOIN oltp.orders o ON o.customer_id = c.customer_id
    LEFT JOIN oltp.transactions t ON t.order_id = o.order_id
    GROUP BY c.customer_id
), scored AS (
    SELECT
        customer_id,
        CURRENT_DATE - COALESCE(last_order_date, CURRENT_DATE) AS recency_days,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY CURRENT_DATE - COALESCE(last_order_date, CURRENT_DATE) DESC) AS recency_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS monetary_score
    FROM rfm_base
)
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    CASE
        WHEN recency_score = 1 AND frequency_score = 4 AND monetary_score = 4 THEN 'Champions'
        WHEN recency_score <= 2 AND monetary_score >= 3 THEN 'High Value'
        WHEN recency_score >= 3 AND frequency_score <= 2 THEN 'At Risk'
        ELSE 'Regular'
    END AS segment
FROM scored
ORDER BY monetary DESC;
