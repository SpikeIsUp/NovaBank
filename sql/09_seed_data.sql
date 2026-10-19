INSERT INTO core.customers (
    first_name,
    last_name,
    email,
    phone,
    birth_date,
    kyc_status,
    risk_level
)
SELECT
    'Client' || n,
    'NovaBank' || n,
    'client' || n || '@novabank.test',
    '0600000000',
    DATE '1980-01-01' + (n % 8000),
    'VERIFIED',
    'LOW'
FROM generate_series(1, 1000) AS n;
