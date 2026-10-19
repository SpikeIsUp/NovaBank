CREATE TABLE core.transactions (
    tx_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    account_id bigint NOT NULL
        REFERENCES core.accounts(account_id),

    tx_type varchar(20) NOT NULL,

    amount numeric(14,2) NOT NULL,

    balance_after numeric(14,2) NOT NULL,

    transfer_id bigint
        REFERENCES core.transfers(transfer_id),

    created_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT ck_transactions_type
        CHECK (tx_type IN (
            'DEPOSIT',
            'WITHDRAWAL',
            'TRANSFER_IN',
            'TRANSFER_OUT'
        )),

    CONSTRAINT ck_transactions_amount
        CHECK (amount <> 0),

    CONSTRAINT ck_transactions_balance
        CHECK (balance_after >= 0),

    CONSTRAINT ck_transactions_transfer
        CHECK (
            (tx_type IN ('TRANSFER_IN', 'TRANSFER_OUT')
                AND transfer_id IS NOT NULL)
            OR
            (tx_type IN ('DEPOSIT', 'WITHDRAWAL')
                AND transfer_id IS NULL)
        ),

    CONSTRAINT ck_transactions_direction
        CHECK (
            (tx_type IN ('DEPOSIT', 'TRANSFER_IN') AND amount > 0)
            OR
            (tx_type IN ('WITHDRAWAL', 'TRANSFER_OUT') AND amount < 0)
        )
);
