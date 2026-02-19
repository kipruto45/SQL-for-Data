-- Store daily row counts for trend monitoring.
INSERT INTO monitoring.row_count_history (table_name, snapshot_date, row_count)
SELECT 'oltp.customers', CURRENT_DATE, COUNT(*) FROM oltp.customers
ON CONFLICT (table_name, snapshot_date) DO UPDATE SET row_count = EXCLUDED.row_count, recorded_at = NOW();

INSERT INTO monitoring.row_count_history (table_name, snapshot_date, row_count)
SELECT 'oltp.orders', CURRENT_DATE, COUNT(*) FROM oltp.orders
ON CONFLICT (table_name, snapshot_date) DO UPDATE SET row_count = EXCLUDED.row_count, recorded_at = NOW();

INSERT INTO monitoring.row_count_history (table_name, snapshot_date, row_count)
SELECT 'oltp.transactions', CURRENT_DATE, COUNT(*) FROM oltp.transactions
ON CONFLICT (table_name, snapshot_date) DO UPDATE SET row_count = EXCLUDED.row_count, recorded_at = NOW();

-- Flag abrupt row-count swings compared to previous day (>50%).
SELECT
    curr.table_name,
    curr.snapshot_date,
    curr.row_count AS current_count,
    prev.row_count AS previous_count,
    ROUND(((curr.row_count - prev.row_count)::NUMERIC / NULLIF(prev.row_count, 0)) * 100, 2) AS pct_change
FROM monitoring.row_count_history curr
JOIN monitoring.row_count_history prev
    ON prev.table_name = curr.table_name
   AND prev.snapshot_date = curr.snapshot_date - 1
WHERE ABS((curr.row_count - prev.row_count)::NUMERIC / NULLIF(prev.row_count, 0)) > 0.50
ORDER BY curr.table_name;
