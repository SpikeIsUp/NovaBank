CREATE MATERIALIZED VIEW core.mv_account_stats AS
SELECT
    a.account_id,
    a.customer_id,
    a.account_type,
    a.balance,
    COUNT(t.tx_id) AS total_transactions,
    COALESCE(
        SUM(t.amount) FILTER (WHERE t.amount > 0),
        0
    ) AS total_received,
    COALESCE(
        SUM(-t.amount) FILTER (WHERE t.amount < 0),
        0
    ) AS total_sent
FROM core.accounts a
LEFT JOIN core.transactions t
    ON a.account_id = t.account_id
GROUP BY
    a.account_id,
    a.customer_id,
    a.account_type,
    a.balance;

CREATE UNIQUE INDEX idx_mv_account_stats_id
ON core.mv_account_stats(account_id);
