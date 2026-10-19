CREATE OR REPLACE FUNCTION core.make_transfer(
    p_from_account bigint,
    p_to_account bigint,
    p_amount numeric,
    p_label text DEFAULT NULL
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
DECLARE
    v_transfer_id bigint;
    v_from_balance numeric(14,2);
    v_from_status varchar(20);
    v_to_status varchar(20);
BEGIN
    -- Verification du montant
    IF p_amount IS NULL
       OR p_amount <= 0
       OR p_amount <> round(p_amount, 2)
       OR p_amount > 999999999999.99
    THEN
        RAISE EXCEPTION 'Invalid transfer amount';
    END IF;

    -- Verification des comptes
    IF p_from_account IS NULL
       OR p_to_account IS NULL
       OR p_from_account = p_to_account
    THEN
        RAISE EXCEPTION 'Invalid source or destination';
    END IF;

    -- Verrouillage dans un ordre stable
    PERFORM 1
    FROM core.accounts
    WHERE account_id IN (p_from_account, p_to_account)
    ORDER BY account_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Accounts not found';
    END IF;

    -- Verifier le compte emetteur
    SELECT balance, status
    INTO v_from_balance, v_from_status
    FROM core.accounts
    WHERE account_id = p_from_account;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Source account not found';
    END IF;

    -- Verifier le compte destinataire
    SELECT status
    INTO v_to_status
    FROM core.accounts
    WHERE account_id = p_to_account;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Destination account not found';
    END IF;

    IF v_from_status <> 'ACTIVE'
       OR v_to_status <> 'ACTIVE'
    THEN
        RAISE EXCEPTION 'Both accounts must be active';
    END IF;

    IF v_from_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient funds';
    END IF;

    -- Creer le virement
    INSERT INTO core.transfers (
        from_account_id,
        to_account_id,
        amount,
        label
    )
    VALUES (
        p_from_account,
        p_to_account,
        p_amount,
        p_label
    )
    RETURNING transfer_id INTO v_transfer_id;

    -- Ecriture de debit
    INSERT INTO core.transactions (
        account_id,
        tx_type,
        amount,
        balance_after,
        transfer_id
    )
    VALUES (
        p_from_account,
        'TRANSFER_OUT',
        -p_amount,
        0,
        v_transfer_id
    );

    -- Ecriture de credit
    INSERT INTO core.transactions (
        account_id,
        tx_type,
        amount,
        balance_after,
        transfer_id
    )
    VALUES (
        p_to_account,
        'TRANSFER_IN',
        p_amount,
        0,
        v_transfer_id
    );

    RETURN v_transfer_id;
END;
$$;

-- Retirer l'execution publique par defaut
REVOKE ALL ON FUNCTION core.make_transfer(
    bigint, bigint, numeric, text
) FROM PUBLIC;

-- Autoriser uniquement l'application
GRANT EXECUTE ON FUNCTION core.make_transfer(
    bigint, bigint, numeric, text
) TO bank_app;
