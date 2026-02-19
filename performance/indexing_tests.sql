-- Benchmark query plans with and without a focused index.
DROP INDEX IF EXISTS idx_orders_date_status;

EXPLAIN ANALYZE
SELECT order_id, customer_id, order_date, status
FROM oltp.orders
WHERE order_date >= DATE '2026-01-01'
  AND status = 'PAID';

CREATE INDEX IF NOT EXISTS idx_orders_date_status
    ON oltp.orders(order_date, status);

EXPLAIN ANALYZE
SELECT order_id, customer_id, order_date, status
FROM oltp.orders
WHERE order_date >= DATE '2026-01-01'
  AND status = 'PAID';
