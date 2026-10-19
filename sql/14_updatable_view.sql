CREATE OR REPLACE VIEW core.v_active_accounts AS
SELECT
    account_id,
    customer_id,
    iban,
    account_type,
    status,
    opened_at
FROM core.accounts
WHERE status = 'ACTIVE'
WITH LOCAL CHECK OPTION;
