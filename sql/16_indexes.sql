-- Index 1 : recherche des clients par nom
CREATE INDEX idx_customers_last_name
ON core.customers(last_name);

-- Index 2 : recherche des comptes d'un client
CREATE INDEX idx_accounts_customer
ON core.accounts(customer_id);

-- Index 3 : recherche des virements par date
CREATE INDEX idx_transfers_created_at
ON core.transfers(created_at);

-- Index 4 : historique des transactions d'un compte
CREATE INDEX idx_transactions_account_date
ON core.transactions(account_id, created_at DESC);

-- Actualiser les statistiques du planificateur
ANALYZE core.customers;
ANALYZE core.accounts;
ANALYZE core.transfers;
ANALYZE core.transactions;
