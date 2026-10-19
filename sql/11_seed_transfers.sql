BEGIN;

-- Eviter une seconde generation
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM core.transfers)
       OR EXISTS (SELECT 1 FROM core.transactions)
    THEN
        RAISE EXCEPTION 'Data already generated';
    END IF;

    IF (SELECT COUNT(*) FROM core.accounts) <> 2000
       OR EXISTS (
           SELECT 1 FROM core.accounts
           WHERE balance <> 10000
       )
    THEN
        RAISE EXCEPTION 'Expected 2000 accounts at 10000';
    END IF;
END;
$$;

-- Creer une correspondance entre numeros et comptes
CREATE TEMP TABLE seed_accounts AS
SELECT
    account_id,
    ROW_NUMBER() OVER (ORDER BY account_id) AS rn
FROM core.accounts;

CREATE UNIQUE INDEX ON seed_accounts(rn);

-- Generer 500 000 virements
INSERT INTO core.transfers (
    from_account_id,
    to_account_id,
    amount,
    label
)
SELECT
    sender.account_id,
    receiver.account_id,
    1.00,
    'Demo transfer ' || g.n
FROM generate_series(1, 500000) AS g(n)
JOIN seed_accounts sender
    ON sender.rn = ((g.n - 1) % 2000) + 1
JOIN seed_accounts receiver
    ON receiver.rn = (g.n % 2000) + 1;

-- Generer deux ecritures par virement
WITH numbered AS (
    SELECT
        transfer_id,
        from_account_id,
        to_account_id,
        amount,
        ROW_NUMBER() OVER (
            ORDER BY transfer_id
        ) AS rn
    FROM core.transfers
)
INSERT INTO core.transactions (
    account_id,
    tx_type,
    amount,
    balance_after,
    transfer_id
)
SELECT
    from_account_id,
    'TRANSFER_OUT',
    -amount,
    9999.00,
    transfer_id
FROM numbered

UNION ALL

SELECT
    to_account_id,
    'TRANSFER_IN',
    amount,
    10000.00,
    transfer_id
FROM numbered;

COMMIT;
