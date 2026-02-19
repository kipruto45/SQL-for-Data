-- Idempotent helper for adding constraints safely.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'uq_customers_email'
    ) THEN
        ALTER TABLE oltp.customers
        ADD CONSTRAINT uq_customers_email UNIQUE (email);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_orders_status'
    ) THEN
        ALTER TABLE oltp.orders
        ADD CONSTRAINT chk_orders_status
        CHECK (status IN ('PENDING', 'PAID', 'CANCELLED', 'REFUNDED'));
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_orders_currency'
    ) THEN
        ALTER TABLE oltp.orders
        ADD CONSTRAINT chk_orders_currency
        CHECK (currency ~ '^[A-Z]{3}$');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_orders_total_amount'
    ) THEN
        ALTER TABLE oltp.orders
        ADD CONSTRAINT chk_orders_total_amount
        CHECK (total_amount >= 0);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_transactions_status'
    ) THEN
        ALTER TABLE oltp.transactions
        ADD CONSTRAINT chk_transactions_status
        CHECK (status IN ('SUCCESS', 'FAILED', 'CHARGEBACK', 'REFUNDED'));
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_transactions_method'
    ) THEN
        ALTER TABLE oltp.transactions
        ADD CONSTRAINT chk_transactions_method
        CHECK (payment_method IN ('CARD', 'BANK_TRANSFER', 'WALLET'));
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_transactions_amount'
    ) THEN
        ALTER TABLE oltp.transactions
        ADD CONSTRAINT chk_transactions_amount
        CHECK (amount >= 0);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_transactions_risk_score'
    ) THEN
        ALTER TABLE oltp.transactions
        ADD CONSTRAINT chk_transactions_risk_score
        CHECK (risk_score IS NULL OR (risk_score >= 0 AND risk_score <= 100));
    END IF;
END $$;
