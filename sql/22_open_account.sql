CREATE OR REPLACE FUNCTION core.open_account(
    p_customer_id bigint,
    p_iban varchar,
    p_account_type varchar
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
DECLARE
    v_kyc_status varchar(20);
    v_account_id bigint;
BEGIN
    -- Verifier les parametres
    IF p_customer_id IS NULL
       OR p_iban IS NULL
       OR length(p_iban) < 15
       OR length(p_iban) > 34
       OR p_account_type IS NULL
       OR p_account_type NOT IN ('CURRENT', 'SAVINGS')
    THEN
        RAISE EXCEPTION 'Invalid account parameters';
    END IF;

    -- Verifier le client
    SELECT kyc_status
    INTO v_kyc_status
    FROM core.customers
    WHERE customer_id = p_customer_id
    FOR SHARE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

    IF v_kyc_status <> 'VERIFIED' THEN
        RAISE EXCEPTION 'Customer KYC is not verified';
    END IF;

    -- Creer le compte
    INSERT INTO core.accounts (
        customer_id,
        iban,
        account_type,
        balance,
        status
    )
    VALUES (
        p_customer_id,
        p_iban,
        p_account_type,
        0,
        'ACTIVE'
    )
    RETURNING account_id INTO v_account_id;

    RETURN v_account_id;
END;
$$;

-- Interdire l'execution publique
REVOKE ALL ON FUNCTION core.open_account(
    bigint, varchar, varchar
) FROM PUBLIC;

-- Autoriser uniquement l'application
GRANT EXECUTE ON FUNCTION core.open_account(
    bigint, varchar, varchar
) TO bank_app;
