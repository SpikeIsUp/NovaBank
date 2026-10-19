CREATE OR REPLACE FUNCTION core.search_customers_unsafe(
    p_name text
)
RETURNS TABLE (
    customer_id bigint,
    first_name varchar(100),
    last_name varchar(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT customer_id, first_name, last_name
         FROM core.customers
         WHERE last_name = ''' || p_name || '''';
END;
$$;
-- =====================================================
-- C4 : SECURITE ET NETTOYAGE
-- =====================================================

-- Retirer les droits d'execution publics
REVOKE ALL ON FUNCTION core.search_customers_unsafe(text)
FROM PUBLIC;

REVOKE ALL ON FUNCTION core.search_customers_safe(text)
FROM PUBLIC;

-- Supprimer la fonction vulnerable apres demonstration
DROP FUNCTION IF EXISTS core.search_customers_unsafe(text);

-- La fonction securisee reste disponible
