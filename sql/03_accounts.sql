CREATE TABLE core.accounts (
    account_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id bigint NOT NULL
        REFERENCES core.customers(customer_id),

    iban varchar(34) NOT NULL UNIQUE,

    account_type varchar(20) NOT NULL,
    balance numeric(14,2) NOT NULL DEFAULT 0,
    status varchar(20) NOT NULL DEFAULT 'ACTIVE',

    opened_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT ck_accounts_balance
        CHECK (balance >= 0),

    CONSTRAINT ck_accounts_type
        CHECK (account_type IN ('CURRENT', 'SAVINGS')),

    CONSTRAINT ck_accounts_status
        CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED'))
);
