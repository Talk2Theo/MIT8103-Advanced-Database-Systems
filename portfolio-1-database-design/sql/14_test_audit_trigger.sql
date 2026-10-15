
-- MIT 8103 - Advanced Database Systems
-- Theoscyba Security Services
--
-- Script: 14_test_audit_trigger.sql
-- Purpose: Test automatic JSONB audit logging.
--
-- Target database: theoscyba_rebuild_test
--
-- IMPORTANT:
-- Execute only once after confirming the
-- audit function and trigger are enabled.

DO $$
DECLARE
    v_vulnerability_id INTEGER;
    v_current_description TEXT;
    v_updated_rows INTEGER;

BEGIN

    -- Step 1: Find the exact FOLM vulnerability.
    SELECT
        v.vulnerability_id,
        v.vulnerability_description
    INTO STRICT
        v_vulnerability_id,
        v_current_description
    FROM vulnerabilities AS v
    JOIN assets AS a
        ON v.asset_id = a.asset_id
    JOIN clients AS c
        ON a.client_id = c.client_id
    WHERE c.client_name = 'FOLM Nigeria Ltd'
      AND a.asset_name = 'Customer Contacts Server'
      AND v.vulnerability_title =
          'Missing Server Security Patches';

    -- Step 2: Confirm the original description.
    IF v_current_description IS DISTINCT FROM
        'The customer contacts server is missing security patches required to address known software weaknesses.'
    THEN
        RAISE EXCEPTION
            'Audit test stopped: original description does not match';
    END IF;

    -- Step 3: Update exactly the identified record.
    UPDATE vulnerabilities
    SET vulnerability_description =
        'The customer contacts server is missing security patches required to address known software weaknesses. Remediation validation has been scheduled.'
    WHERE vulnerability_id = v_vulnerability_id;

    -- Step 4: Confirm exactly one row was updated.
    GET DIAGNOSTICS v_updated_rows = ROW_COUNT;

    IF v_updated_rows <> 1 THEN
        RAISE EXCEPTION
            'Audit test stopped: expected one updated row, got %',
            v_updated_rows;
    END IF;

    -- Step 5: Report successful completion.
    RAISE NOTICE
        'One FOLM vulnerability updated successfully. Check audit_logs for the captured change.';

END;
$$;
