-- Fonction qui interdit UPDATE et DELETE
CREATE OR REPLACE FUNCTION core.prevent_transaction_changes()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION
        'Bank transactions are immutable: UPDATE and DELETE forbidden';
END;
$$;

-- Trigger de protection
CREATE TRIGGER trg_transactions_immutable
BEFORE UPDATE OR DELETE
ON core.transactions
FOR EACH ROW
EXECUTE FUNCTION core.prevent_transaction_changes();
