CREATE TABLE core.transfers (
    transfer_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    from_account_id bigint NOT NULL
        REFERENCES core.accounts(account_id),

    to_account_id bigint NOT NULL
        REFERENCES core.accounts(account_id),

    amount numeric(14,2) NOT NULL,

    label varchar(255),

    created_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT ck_transfers_amount
        CHECK (amount > 0),

    CONSTRAINT ck_transfers_different_accounts
        CHECK (from_account_id <> to_account_id)
);
