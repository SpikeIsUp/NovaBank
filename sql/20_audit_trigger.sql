-- Fonction d'audit generique
CREATE OR REPLACE FUNCTION audit.log_changes()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN

        INSERT INTO audit.audit_log (
            table_name,
            operation,
            old_data,
            new_data,
            db_user
        )
        VALUES (
            TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME,
            TG_OP,
            NULL,
            to_jsonb(NEW),
            SESSION_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN

        INSERT INTO audit.audit_log (
            table_name,
            operation,
            old_data,
            new_data,
            db_user
        )
        VALUES (
            TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME,
            TG_OP,
            to_jsonb(OLD),
            to_jsonb(NEW),
            SESSION_USER
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN

        INSERT INTO audit.audit_log (
            table_name,
            operation,
            old_data,
            new_data,
            db_user
        )
        VALUES (
            TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME,
            TG_OP,
            to_jsonb(OLD),
            NULL,
            SESSION_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

-- Audit des clients
CREATE TRIGGER trg_audit_customers
AFTER INSERT OR UPDATE OR DELETE
ON core.customers
FOR EACH ROW
EXECUTE FUNCTION audit.log_changes();

-- Audit des comptes
CREATE TRIGGER trg_audit_accounts
AFTER INSERT OR UPDATE OR DELETE
ON core.accounts
FOR EACH ROW
EXECUTE FUNCTION audit.log_changes();

-- Audit des alertes de fraude
CREATE TRIGGER trg_audit_fraud_alerts
AFTER INSERT OR UPDATE OR DELETE
ON core.fraud_alerts
FOR EACH ROW
EXECUTE FUNCTION audit.log_changes();
