CREATE TABLE core.fraud_alerts (
    alert_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    account_id bigint NOT NULL
        REFERENCES core.accounts(account_id),

    tx_id bigint
        REFERENCES core.transactions(tx_id),

    rule_code varchar(50) NOT NULL,

    status varchar(20) NOT NULL DEFAULT 'OPEN',

    created_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT ck_fraud_alerts_rule
        CHECK (rule_code IN (
            'LARGE_WITHDRAWAL',
            'FREQUENT_TRANSFERS'
        )),

    CONSTRAINT ck_fraud_alerts_status
        CHECK (status IN (
            'OPEN',
            'INVESTIGATING',
            'RESOLVED',
            'FALSE_POSITIVE'
        ))
);
