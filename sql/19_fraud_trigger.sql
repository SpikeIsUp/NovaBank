CREATE OR REPLACE FUNCTION core.detect_fraud()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_transfer_count integer;
BEGIN
    -- Regle 1 : retrait important
    IF NEW.tx_type = 'WITHDRAWAL'
       AND NEW.amount <= -5000
    THEN
        INSERT INTO core.fraud_alerts (
            account_id,
            tx_id,
            rule_code
        )
        VALUES (
            NEW.account_id,
            NEW.tx_id,
            'LARGE_WITHDRAWAL'
        );
    END IF;

    -- Regle 2 : 5 virements sortants en 10 minutes
    IF NEW.tx_type = 'TRANSFER_OUT' THEN

        SELECT COUNT(*)
        INTO v_transfer_count
        FROM core.transactions
        WHERE account_id = NEW.account_id
          AND tx_type = 'TRANSFER_OUT'
          AND created_at >= NEW.created_at - INTERVAL '10 minutes'
          AND created_at <= NEW.created_at;

        IF v_transfer_count >= 5 THEN
            INSERT INTO core.fraud_alerts (
                account_id,
                tx_id,
                rule_code
            )
            VALUES (
                NEW.account_id,
                NEW.tx_id,
                'FREQUENT_TRANSFERS'
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_detect_fraud
AFTER INSERT
ON core.transactions
FOR EACH ROW
EXECUTE FUNCTION core.detect_fraud();
