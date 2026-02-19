-- Deterministic segmentation tests.
SET app.segment_as_of_date = '2026-02-19';

-- Test 1: segmentation returns one row per customer and no NULL segment.
DO $$
DECLARE
    v_customers INT;
    v_segmented INT;
    v_null_segments INT;
BEGIN
    SELECT COUNT(*) INTO v_customers FROM oltp.customers;
    SELECT COUNT(*) INTO v_segmented FROM warehouse.v_customer_segmentation;
    SELECT COUNT(*) INTO v_null_segments
    FROM warehouse.v_customer_segmentation
    WHERE segment IS NULL;

    IF v_segmented <> v_customers THEN
        RAISE EXCEPTION 'Segmentation row mismatch: expected %, got %.', v_customers, v_segmented;
    END IF;

    IF v_null_segments > 0 THEN
        RAISE EXCEPTION 'Segmentation contains % NULL segments.', v_null_segments;
    END IF;
END $$;

-- Test 2: segment values are within approved taxonomy.
DO $$
DECLARE
    v_invalid INT;
BEGIN
    SELECT COUNT(*) INTO v_invalid
    FROM warehouse.v_customer_segmentation
    WHERE segment NOT IN ('Champions', 'High Value', 'Loyal', 'At Risk', 'Regular', 'Inactive');

    IF v_invalid > 0 THEN
        RAISE EXCEPTION 'Found % rows with invalid segment labels.', v_invalid;
    END IF;
END $$;

-- Test 3: inactive customers must have zero paid orders and vice versa.
DO $$
DECLARE
    v_mismatch INT;
BEGIN
    SELECT COUNT(*) INTO v_mismatch
    FROM warehouse.v_customer_segmentation
    WHERE (paid_orders = 0 AND segment <> 'Inactive')
       OR (paid_orders > 0 AND segment = 'Inactive');

    IF v_mismatch > 0 THEN
        RAISE EXCEPTION 'Found % rows violating inactive segmentation rule.', v_mismatch;
    END IF;
END $$;

-- Test 4: regression checks for known sample customers.
DO $$
DECLARE
    v_customer_4 TEXT;
    v_customer_6 TEXT;
BEGIN
    SELECT segment INTO v_customer_4
    FROM warehouse.v_customer_segmentation
    WHERE customer_id = 4;

    SELECT segment INTO v_customer_6
    FROM warehouse.v_customer_segmentation
    WHERE customer_id = 6;

    IF v_customer_4 <> 'High Value' THEN
        RAISE EXCEPTION 'Expected customer 4 to be High Value, got %.', COALESCE(v_customer_4, 'NULL');
    END IF;

    IF v_customer_6 <> 'Inactive' THEN
        RAISE EXCEPTION 'Expected customer 6 to be Inactive, got %.', COALESCE(v_customer_6, 'NULL');
    END IF;
END $$;

RESET app.segment_as_of_date;
