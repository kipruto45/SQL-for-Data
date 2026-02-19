-- Monthly cohort retention based on paid order activity.
WITH signup_cohort AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', signup_date)::DATE AS cohort_month
    FROM oltp.customers
), activity AS (
    SELECT DISTINCT
        o.customer_id,
        DATE_TRUNC('month', o.order_date)::DATE AS activity_month
    FROM oltp.orders o
    WHERE o.status = 'PAID'
), combined AS (
    SELECT
        c.cohort_month,
        a.activity_month,
        EXTRACT(YEAR FROM AGE(a.activity_month, c.cohort_month)) * 12
            + EXTRACT(MONTH FROM AGE(a.activity_month, c.cohort_month)) AS month_number,
        c.customer_id
    FROM signup_cohort c
    JOIN activity a
        ON a.customer_id = c.customer_id
    WHERE a.activity_month >= c.cohort_month
)
SELECT
    cohort_month,
    month_number::INT,
    COUNT(DISTINCT customer_id) AS active_customers
FROM combined
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number;
