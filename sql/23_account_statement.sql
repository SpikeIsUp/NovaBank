CREATE OR REPLACE FUNCTION core.get_account_statement(
    p_account_id bigint,
    p_start_date timestamptz,
    p_end_date timestamptz
)
RETURNS TABLE (
    tx_id bigint,
    tx_date timestamptz,
    tx_type varchar(20),
    amount numeric(14,2),
    balance_after numeric(14,2),
    transfer_id bigint
)
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
BEGIN
    IF p_account_id IS NULL
       OR p_start_date IS NULL
       OR p_end_date IS NULL
       OR p_start_date > p_end_date
    THEN
        RAISE EXCEPTION 'Invalid statement parameters';
    END IF;

    RETURN QUERY
    SELECT
        t.tx_id,
        t.created_at,
        t.tx_type,
        t.amount,
        t.balance_after,
        t.transfer_id
    FROM core.transactions t
    WHERE t.account_id = p_account_id
      AND t.created_at >= p_start_date
      AND t.created_at < p_end_date
    ORDER BY t.created_at, t.tx_id;
END;
$$;

REVOKE ALL ON FUNCTION core.get_account_statement(
    bigint, timestamptz, timestamptz
) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION core.get_account_statement(
    bigint, timestamptz, timestamptz
) TO analystes;
