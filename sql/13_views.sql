CREATE OR REPLACE VIEW core.v_customers_masked AS
SELECT
    customer_id,
    first_name,
    last_name,

    LEFT(email, 1) || '***@' ||
    SPLIT_PART(email, '@', 2) AS email_masked,

    CASE
        WHEN phone IS NULL THEN NULL
        ELSE '******' || RIGHT(phone, 4)
    END AS phone_masked,

    kyc_status,
    risk_level,
    created_at
FROM core.customers;
-- Autoriser la lecture de la vue
GRANT SELECT ON core.v_customers_masked
TO analystes, support;

-- Retirer l'accès direct aux données personnelles
REVOKE SELECT ON core.customers
FROM analystes, support;
