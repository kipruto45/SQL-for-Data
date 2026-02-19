-- Rule-based segmentation with explicit thresholds.
-- Optional deterministic date for tests:
--   SET app.segment_as_of_date = '2026-02-19';

CREATE OR REPLACE VIEW warehouse.v_customer_segmentation AS
WITH params AS (
    SELECT COALESCE(
        NULLIF(current_setting('app.segment_as_of_date', true), '')::DATE,
        CURRENT_DATE
    ) AS as_of_date
), thresholds AS (
    SELECT
        30::INT AS champion_max_recency_days,
        3::INT AS champion_min_paid_orders,
        400::NUMERIC(12,2) AS champion_min_revenue,
        60::INT AS high_value_max_recency_days,
        300::NUMERIC(12,2) AS high_value_min_revenue,
        3::INT AS loyal_min_paid_orders,
        90::INT AS loyal_max_recency_days,
        75::INT AS at_risk_min_recency_days
), customer_kpis AS (
    SELECT
        c.customer_id,
        c.signup_date,
        MAX(o.order_date) FILTER (WHERE o.status = 'PAID') AS last_paid_order_date,
        COUNT(DISTINCT o.order_id) FILTER (WHERE o.status = 'PAID') AS paid_orders,
        COALESCE(SUM(t.amount) FILTER (WHERE o.status = 'PAID' AND t.status = 'SUCCESS'), 0) AS lifetime_revenue
    FROM oltp.customers c
    LEFT JOIN oltp.orders o
        ON o.customer_id = c.customer_id
    LEFT JOIN oltp.transactions t
        ON t.order_id = o.order_id
    GROUP BY c.customer_id, c.signup_date
), segmentation_base AS (
    SELECT
        ck.customer_id,
        p.as_of_date,
        (p.as_of_date - COALESCE(ck.last_paid_order_date, ck.signup_date, p.as_of_date))::INT AS recency_days,
        ck.paid_orders,
        ck.lifetime_revenue,
        ROUND(ck.lifetime_revenue / NULLIF(ck.paid_orders, 0), 2) AS avg_paid_order_value
    FROM customer_kpis ck
    CROSS JOIN params p
)
SELECT
    sb.customer_id,
    sb.as_of_date,
    sb.recency_days,
    sb.paid_orders,
    sb.lifetime_revenue,
    sb.avg_paid_order_value,
    CASE
        WHEN sb.paid_orders = 0 THEN 'Inactive'
        WHEN sb.recency_days <= t.champion_max_recency_days
             AND sb.paid_orders >= t.champion_min_paid_orders
             AND sb.lifetime_revenue >= t.champion_min_revenue
            THEN 'Champions'
        WHEN sb.recency_days <= t.high_value_max_recency_days
             AND sb.lifetime_revenue >= t.high_value_min_revenue
            THEN 'High Value'
        WHEN sb.paid_orders >= t.loyal_min_paid_orders
             AND sb.recency_days <= t.loyal_max_recency_days
            THEN 'Loyal'
        WHEN sb.recency_days >= t.at_risk_min_recency_days
            THEN 'At Risk'
        ELSE 'Regular'
    END AS segment
FROM segmentation_base sb
CROSS JOIN thresholds t;

SELECT
    customer_id,
    as_of_date,
    recency_days,
    paid_orders,
    lifetime_revenue,
    avg_paid_order_value,
    segment
FROM warehouse.v_customer_segmentation
ORDER BY lifetime_revenue DESC, paid_orders DESC, customer_id;
