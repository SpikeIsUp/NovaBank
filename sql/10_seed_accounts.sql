INSERT INTO core.accounts (
    customer_id,
    iban,
    account_type,
    balance,
    status
)
SELECT
    c.customer_id,
    'FR76' || LPAD(
        (c.customer_id * 2 + n)::text,
        23,
        '0'
    ),
    CASE
        WHEN n = 1 THEN 'CURRENT'
        ELSE 'SAVINGS'
    END,
    10000.00,
    'ACTIVE'
FROM core.customers c
CROSS JOIN generate_series(1, 2) AS n
ON CONFLICT (iban) DO NOTHING;
