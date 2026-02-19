-- Validate critical quality conditions.
DO $$
DECLARE
    v_failed INT;
BEGIN
    SELECT COUNT(*) INTO v_failed
    FROM oltp.customers
    WHERE email !~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$';

    IF v_failed > 0 THEN
        RAISE EXCEPTION 'Quality failure: % invalid customer emails.', v_failed;
    END IF;
END $$;

DO $$
DECLARE
    v_failed INT;
BEGIN
    SELECT COUNT(*) INTO v_failed
    FROM oltp.transactions
    WHERE amount <= 0;

    IF v_failed > 0 THEN
        RAISE EXCEPTION 'Quality failure: % transactions with non-positive amount.', v_failed;
    END IF;
END $$;

DO $$
DECLARE
    v_failed INT;
BEGIN
    SELECT COUNT(*) INTO v_failed
    FROM oltp.orders
    WHERE status NOT IN ('PENDING', 'PAID', 'CANCELLED', 'REFUNDED');

    IF v_failed > 0 THEN
        RAISE EXCEPTION 'Quality failure: % invalid order statuses.', v_failed;
    END IF;
END $$;
