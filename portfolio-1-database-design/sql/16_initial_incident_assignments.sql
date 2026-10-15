
-- MIT 8103 - Advanced Database Systems
-- Theoscyba Security Services
--
-- Script: 16_initial_incident_assignments.sql
-- Purpose: Recreate three initial incident assignments.
--
-- Target database: theoscyba_rebuild_test
--
-- Expected results:
-- 3 total assignments
-- 3 active assignments
-- 0 ended assignments
--
-- Execute BEFORE 18_incident_handover.sql.
-- Do not execute repeatedly.

DO $$
DECLARE
    rec RECORD;

    v_incident_id INTEGER;
    v_analyst_id INTEGER;
    v_inserted_count INTEGER := 0;

BEGIN

    -- Step 1: Protect the original database.

    IF current_database() <> 'theoscyba_rebuild_test' THEN
        RAISE EXCEPTION
            'Wrong database. Expected theoscyba_rebuild_test.';
    END IF;

    -- Step 2: Confirm the assignment table is empty.

    IF EXISTS (
        SELECT 1
        FROM incident_assignments
    ) THEN
        RAISE EXCEPTION
            'Initial assignment insertion stopped: assignment records already exist.';
    END IF;

    -- Step 3: Verify the expected four incidents exist.

    IF (
        SELECT COUNT(*)
        FROM incidents
    ) <> 4 THEN
        RAISE EXCEPTION
            'Expected exactly four incidents before creating assignments.';
    END IF;

    -- Step 4: Define the three initial assignments.

    FOR rec IN
        SELECT *
        FROM (
            VALUES

            (
                'PaySecure Fintech Ltd',
                'Payment Application Server',
                'Suspicious VPN Sign-in',
                'chineze.okafor@theoscyba.example'
            ),

            (
                'MedTrust Hospital',
                'Patient Records Server',
                'Malware Detected on Records Server',
                'chineze.okafor@theoscyba.example'
            ),

            (
                'ShopEase Nigeria Ltd',
                'E-commerce Web Server',
                'Repeated Failed Login Attempts',
                'amina.yusuf@theoscyba.example'
            )

        ) AS expected (
            client_name,
            asset_name,
            incident_title,
            analyst_email
        )

    LOOP

        -- Step 5: Find exactly one incident with
        -- the expected current analyst.

        SELECT
            i.incident_id,
            i.assigned_analyst_id
        INTO STRICT
            v_incident_id,
            v_analyst_id

        FROM incidents AS i

        JOIN assets AS a
            ON i.asset_id = a.asset_id

        JOIN clients AS c
            ON a.client_id = c.client_id

        JOIN analysts AS an
            ON i.assigned_analyst_id = an.analyst_id

        WHERE c.client_name = rec.client_name
          AND a.asset_name = rec.asset_name
          AND i.incident_title = rec.incident_title
          AND an.email = rec.analyst_email;

        -- Step 6: Insert the initial assignment.

        INSERT INTO incident_assignments (
            incident_id,
            analyst_id,
            assigned_by_analyst_id,
            assignment_reason
        )
        VALUES (
            v_incident_id,
            v_analyst_id,
            NULL,
            'Initial incident assignment reconstructed during database rebuild'
        );

        v_inserted_count := v_inserted_count + 1;

    END LOOP;

    -- Step 7: Confirm exactly three were inserted.

    IF v_inserted_count <> 3 THEN
        RAISE EXCEPTION
            'Expected three assignments, inserted %.',
            v_inserted_count;
    END IF;

    RAISE NOTICE
        'Successfully created % initial incident assignments.',
        v_inserted_count;

END;
$$;
