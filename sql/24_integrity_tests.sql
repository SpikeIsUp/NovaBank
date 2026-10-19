-- TEST 1 : Nombre de clients
SELECT COUNT(*) AS total_customers
FROM core.customers;

-- TEST 2 : Nombre de comptes
SELECT COUNT(*) AS total_accounts
FROM core.accounts;

-- TEST 3 : Nombre de virements
SELECT COUNT(*) AS total_transfers
FROM core.transfers;

-- TEST 4 : Nombre d'ecritures
SELECT COUNT(*) AS total_transactions
FROM core.transactions;

-- TEST 5 : Comptes avec un solde negatif
SELECT COUNT(*) AS negative_balances
FROM core.accounts
WHERE balance < 0;

-- TEST 6 : Virements sans exactement deux ecritures
SELECT COUNT(*) AS invalid_transfers
FROM (
    SELECT
        tr.transfer_id,
        COUNT(tx.tx_id) AS entries
    FROM core.transfers tr
    LEFT JOIN core.transactions tx
        ON tx.transfer_id = tr.transfer_id
    GROUP BY tr.transfer_id
    HAVING COUNT(tx.tx_id) <> 2
) AS invalid;

-- TEST 7 : Virements avec des ecritures incoherentes
SELECT COUNT(*) AS inconsistent_transfers
FROM (
    SELECT
        tr.transfer_id
    FROM core.transfers tr
    LEFT JOIN core.transactions tx
        ON tx.transfer_id = tr.transfer_id
    GROUP BY
        tr.transfer_id,
        tr.from_account_id,
        tr.to_account_id,
        tr.amount
    HAVING
        COUNT(tx.tx_id) <> 2
        OR COUNT(*) FILTER (
            WHERE tx.account_id = tr.from_account_id
              AND tx.tx_type = 'TRANSFER_OUT'
              AND tx.amount = -tr.amount
        ) <> 1
        OR COUNT(*) FILTER (
            WHERE tx.account_id = tr.to_account_id
              AND tx.tx_type = 'TRANSFER_IN'
              AND tx.amount = tr.amount
        ) <> 1
) AS inconsistent;

-- TEST 8 : Ecritures orphelines
SELECT COUNT(*) AS orphan_transactions
FROM core.transactions tx
LEFT JOIN core.transfers tr
    ON tr.transfer_id = tx.transfer_id
WHERE tx.transfer_id IS NOT NULL
  AND tr.transfer_id IS NULL;
