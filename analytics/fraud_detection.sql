-- High-risk transactions with material amount.
SELECT
    t.transaction_id,
    t.order_id,
    o.customer_id,
    t.transaction_date,
    t.amount,
    t.status,
    t.risk_score
FROM oltp.transactions t
JOIN oltp.orders o ON o.order_id = t.order_id
WHERE t.risk_score >= 80
   OR (t.status IN ('FAILED', 'CHARGEBACK') AND t.amount >= 200)
ORDER BY t.risk_score DESC NULLS LAST, t.transaction_date DESC;

-- Consecutive failed attempts within 15 minutes per order.
WITH failed AS (
    SELECT
        transaction_id,
        order_id,
        transaction_date,
        LAG(transaction_date) OVER (PARTITION BY order_id ORDER BY transaction_date) AS prev_txn_time
    FROM oltp.transactions
    WHERE status = 'FAILED'
)
SELECT
    transaction_id,
    order_id,
    transaction_date,
    prev_txn_time,
    EXTRACT(EPOCH FROM (transaction_date - prev_txn_time)) / 60.0 AS minutes_since_previous
FROM failed
WHERE prev_txn_time IS NOT NULL
  AND transaction_date - prev_txn_time <= INTERVAL '15 minutes'
ORDER BY order_id, transaction_date;
