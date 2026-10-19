CREATE OR REPLACE FUNCTION core.update_account_balance()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_balance numeric(14,2);
    v_status varchar(20);
BEGIN
    -- Verrouiller le compte pendant l'operation
    SELECT balance, status
    INTO v_balance, v_status
    FROM core.accounts
    WHERE account_id = NEW.account_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account does not exist';
    END IF;

    IF v_status <> 'ACTIVE' THEN
        RAISE EXCEPTION 'Account is not active';
    END IF;

    -- Calculer le nouveau solde
    v_balance := v_balance + NEW.amount;

    IF v_balance < 0 THEN
        RAISE EXCEPTION 'Insufficient funds';
    END IF;

    -- Mettre a jour le solde du compte
    UPDATE core.accounts
    SET balance = v_balance
    WHERE account_id = NEW.account_id;

    -- Enregistrer le solde apres transaction
    NEW.balance_after := v_balance;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_update_account_balance
BEFORE INSERT
ON core.transactions
FOR EACH ROW
EXECUTE FUNCTION core.update_account_balance();
