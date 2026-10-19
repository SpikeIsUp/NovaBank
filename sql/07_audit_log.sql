CREATE SCHEMA IF NOT EXISTS audit AUTHORIZATION bank_owner;

CREATE TABLE audit.audit_log (
    log_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    table_name varchar(100) NOT NULL,

    operation varchar(10) NOT NULL,

    old_data jsonb,

    new_data jsonb,

    db_user name NOT NULL DEFAULT current_user,

    changed_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT ck_audit_operation
        CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE'))
);
