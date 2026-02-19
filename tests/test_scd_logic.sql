-- Ensure one current record per business key.
DO $$
DECLARE
    v_invalid INT;
BEGIN
    SELECT COUNT(*) INTO v_invalid
    FROM (
        SELECT customer_id
        FROM warehouse.dim_customer
        WHERE is_current = TRUE
        GROUP BY customer_id
        HAVING COUNT(*) > 1
    ) x;

    IF v_invalid > 0 THEN
        RAISE EXCEPTION 'SCD failure: % customers have multiple current rows.', v_invalid;
    END IF;
END $$;

-- Ensure SCD periods do not overlap for same customer.
DO $$
DECLARE
    v_overlap INT;
BEGIN
    SELECT COUNT(*) INTO v_overlap
    FROM warehouse.dim_customer d1
    JOIN warehouse.dim_customer d2
      ON d1.customer_id = d2.customer_id
     AND d1.customer_sk <> d2.customer_sk
     AND d1.valid_from <= d2.valid_to
     AND d2.valid_from <= d1.valid_to;

    IF v_overlap > 0 THEN
        RAISE EXCEPTION 'SCD failure: % overlapping SCD periods found.', v_overlap;
    END IF;
END $$;
