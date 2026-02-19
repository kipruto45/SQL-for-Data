CREATE INDEX IF NOT EXISTS idx_customers_country_signup
    ON oltp.customers(country, signup_date);

CREATE INDEX IF NOT EXISTS idx_orders_customer_date
    ON oltp.orders(customer_id, order_date);

CREATE INDEX IF NOT EXISTS idx_orders_status
    ON oltp.orders(status);

CREATE INDEX IF NOT EXISTS idx_transactions_order_date
    ON oltp.transactions(order_id, transaction_date);

CREATE INDEX IF NOT EXISTS idx_transactions_status_risk
    ON oltp.transactions(status, risk_score);

CREATE INDEX IF NOT EXISTS idx_transactions_high_risk_partial
    ON oltp.transactions(transaction_date)
    WHERE risk_score >= 80;
