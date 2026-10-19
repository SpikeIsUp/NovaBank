CREATE TABLE core.customers (
    customer_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    first_name varchar(100) NOT NULL,
    last_name varchar(100) NOT NULL,

    email varchar(255) NOT NULL UNIQUE,
    phone varchar(30),

    birth_date date NOT NULL,

    kyc_status varchar(20) NOT NULL DEFAULT 'PENDING',
    risk_level varchar(20) NOT NULL DEFAULT 'LOW',

    created_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT ck_customers_email
        CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),

    CONSTRAINT ck_customers_kyc
        CHECK (kyc_status IN ('PENDING', 'VERIFIED', 'REJECTED')),

    CONSTRAINT ck_customers_risk
        CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH'))
);
