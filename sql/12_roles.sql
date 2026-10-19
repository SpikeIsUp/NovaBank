-- Groupes de permissions (sans connexion directe)
CREATE ROLE analystes NOLOGIN;
CREATE ROLE support NOLOGIN;
CREATE ROLE auditeurs NOLOGIN;

-- Comptes utilisateurs
CREATE ROLE bank_analyst LOGIN PASSWORD 'analyst01!';
CREATE ROLE bank_support LOGIN PASSWORD 'support02!';
CREATE ROLE bank_app LOGIN PASSWORD 'bank_app03!';
CREATE ROLE bank_auditor LOGIN PASSWORD 'auditor04!';

-- Affectation des utilisateurs aux groupes
GRANT analystes TO bank_analyst;
GRANT support TO bank_support;
GRANT auditeurs TO bank_auditor;

-- Autoriser la connexion a la base
GRANT CONNECT ON DATABASE bankdb
TO analystes, support, auditeurs, bank_app;

-- Autoriser l'acces aux schemas
GRANT USAGE ON SCHEMA core
TO analystes, support, auditeurs, bank_app;

GRANT USAGE ON SCHEMA audit
TO auditeurs;

-- Analystes : lecture uniquement
GRANT SELECT ON
    core.customers,
    core.accounts,
    core.transfers,
    core.transactions
TO analystes;

-- Support : consultation clients et comptes
GRANT SELECT ON
    core.customers,
    core.accounts
TO support;

-- Auditeurs : consultation des journaux
GRANT SELECT ON audit.audit_log
TO auditeurs;
