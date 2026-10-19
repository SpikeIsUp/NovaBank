CREATE OR REPLACE FUNCTION core.check_customer_age()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.birth_date IS NULL
       OR NEW.birth_date > (CURRENT_DATE - INTERVAL '18 years')::date
    THEN
        RAISE EXCEPTION 'Customer must be at least 18 years old';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_customer_age
BEFORE INSERT OR UPDATE OF birth_date
ON core.customers
FOR EACH ROW
EXECUTE FUNCTION core.check_customer_age();
