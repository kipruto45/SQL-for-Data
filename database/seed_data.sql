-- Optional: seed OLTP tables directly (bypasses staging).
INSERT INTO oltp.customers (
    customer_id, first_name, last_name, email, phone, city, country, signup_date, updated_at
)
VALUES
    (1, 'Alice', 'Johnson', 'alice.johnson@example.com', '+1-555-1001', 'Austin', 'US', '2024-01-15', '2026-01-01T10:00:00Z'),
    (2, 'Bob', 'Smith', 'bob.smith@example.com', '+1-555-1002', 'Portland', 'US', '2024-02-11', '2026-01-12T09:30:00Z'),
    (3, 'Carol', 'Nguyen', 'carol.nguyen@example.com', '+1-555-1003', 'Denver', 'US', '2024-03-05', '2026-01-03T11:45:00Z'),
    (4, 'David', 'Lopez', 'david.lopez@example.com', '+1-555-1004', 'Miami', 'US', '2024-05-20', '2026-01-04T14:15:00Z'),
    (5, 'Eva', 'Brown', 'eva.brown@example.com', '+1-555-1005', 'Boston', 'US', '2024-07-09', '2026-01-05T08:10:00Z'),
    (6, 'Frank', 'Kim', 'frank.kim@example.com', '+1-555-1006', 'Chicago', 'US', '2025-01-17', '2026-01-06T12:00:00Z')
ON CONFLICT (customer_id) DO UPDATE
SET
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    email = EXCLUDED.email,
    phone = EXCLUDED.phone,
    city = EXCLUDED.city,
    country = EXCLUDED.country,
    signup_date = EXCLUDED.signup_date,
    updated_at = EXCLUDED.updated_at;

INSERT INTO oltp.orders (
    order_id, customer_id, order_date, status, total_amount, currency, updated_at
)
VALUES
    (1001, 1, '2025-12-15', 'PAID', 120.50, 'USD', '2026-01-10T10:20:00Z'),
    (1002, 2, '2025-12-16', 'PAID', 89.99, 'USD', '2026-01-10T10:25:00Z'),
    (1003, 2, '2025-12-18', 'CANCELLED', 49.00, 'USD', '2026-01-11T09:10:00Z'),
    (1004, 3, '2025-12-20', 'PAID', 215.00, 'USD', '2026-01-11T10:00:00Z'),
    (1005, 4, '2026-01-05', 'PAID', 560.00, 'USD', '2026-01-15T08:00:00Z'),
    (1006, 5, '2026-01-08', 'PAID', 45.25, 'USD', '2026-01-12T09:00:00Z'),
    (1007, 6, '2026-01-10', 'REFUNDED', 199.99, 'USD', '2026-01-12T10:00:00Z')
ON CONFLICT (order_id) DO UPDATE
SET
    customer_id = EXCLUDED.customer_id,
    order_date = EXCLUDED.order_date,
    status = EXCLUDED.status,
    total_amount = EXCLUDED.total_amount,
    currency = EXCLUDED.currency,
    updated_at = EXCLUDED.updated_at;

INSERT INTO oltp.transactions (
    transaction_id, order_id, transaction_date, payment_method, amount, status, risk_score, updated_at
)
VALUES
    (5001, 1001, '2025-12-15T12:10:00Z', 'CARD', 120.50, 'SUCCESS', 12.5, '2026-01-10T10:22:00Z'),
    (5002, 1002, '2025-12-16T16:00:00Z', 'BANK_TRANSFER', 89.99, 'SUCCESS', 20.0, '2026-01-10T10:26:00Z'),
    (5003, 1003, '2025-12-18T09:30:00Z', 'CARD', 49.00, 'REFUNDED', 15.0, '2026-01-11T09:15:00Z'),
    (5004, 1004, '2025-12-20T20:45:00Z', 'WALLET', 215.00, 'SUCCESS', 18.0, '2026-01-11T10:05:00Z'),
    (5005, 1005, '2026-01-05T14:20:00Z', 'CARD', 560.00, 'FAILED', 82.0, '2026-01-12T08:05:00Z'),
    (5006, 1005, '2026-01-05T14:25:00Z', 'CARD', 560.00, 'SUCCESS', 75.0, '2026-01-15T08:05:00Z'),
    (5007, 1006, '2026-01-08T09:50:00Z', 'CARD', 45.25, 'SUCCESS', 10.0, '2026-01-12T09:05:00Z'),
    (5008, 1007, '2026-01-10T18:00:00Z', 'BANK_TRANSFER', 199.99, 'CHARGEBACK', 91.0, '2026-01-12T10:05:00Z')
ON CONFLICT (transaction_id) DO UPDATE
SET
    order_id = EXCLUDED.order_id,
    transaction_date = EXCLUDED.transaction_date,
    payment_method = EXCLUDED.payment_method,
    amount = EXCLUDED.amount,
    status = EXCLUDED.status,
    risk_score = EXCLUDED.risk_score,
    updated_at = EXCLUDED.updated_at;
