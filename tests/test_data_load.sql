-- Test 1: OLTP tables contain records.
DO $$
DECLARE
    v_customers INT;
    v_orders INT;
    v_transactions INT;
BEGIN
    SELECT COUNT(*) INTO v_customers FROM oltp.customers;
    SELECT COUNT(*) INTO v_orders FROM oltp.orders;
    SELECT COUNT(*) INTO v_transactions FROM oltp.transactions;

    IF v_customers = 0 OR v_orders = 0 OR v_transactions = 0 THEN
        RAISE EXCEPTION 'Data load failed: customers=%, orders=%, transactions=%',
            v_customers, v_orders, v_transactions;
    END IF;
END $$;

-- Test 2: no orphan orders.
DO $$
DECLARE
    v_orphans INT;
BEGIN
    SELECT COUNT(*) INTO v_orphans
    FROM oltp.orders o
    LEFT JOIN oltp.customers c ON c.customer_id = o.customer_id
    WHERE c.customer_id IS NULL;

    IF v_orphans > 0 THEN
        RAISE EXCEPTION 'Found % orphan orders.', v_orphans;
    END IF;
END $$;

-- Test 3: no orphan transactions.
DO $$
DECLARE
    v_orphans INT;
BEGIN
    SELECT COUNT(*) INTO v_orphans
    FROM oltp.transactions t
    LEFT JOIN oltp.orders o ON o.order_id = t.order_id
    WHERE o.order_id IS NULL;

    IF v_orphans > 0 THEN
        RAISE EXCEPTION 'Found % orphan transactions.', v_orphans;
    END IF;
END $$;
