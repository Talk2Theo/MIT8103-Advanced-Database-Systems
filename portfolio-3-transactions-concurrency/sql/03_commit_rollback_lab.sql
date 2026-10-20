
-- MIT 8103 - Portfolio 3
-- Script 03: COMMIT and ROLLBACK
-- Theoscyba Security Services

-- Safety check
DO $$
BEGIN
    IF current_database() <> 'theoscyba_portfolio3_lab' THEN
        RAISE EXCEPTION 'Wrong database selected!';
    END IF;
END;
$$;

-- ==================================
-- EXPERIMENT 1: COMMIT
-- ==================================

BEGIN;

UPDATE public.p3_incidents
SET status = 'Investigating'
WHERE incident_id = 101;

-- Confirm change inside transaction
SELECT incident_id, incident_title, status
FROM public.p3_incidents
WHERE incident_id = 101;

COMMIT;

-- Confirm committed change persists
SELECT incident_id, incident_title, status
FROM public.p3_incidents
WHERE incident_id = 101;


-- ==================================
-- EXPERIMENT 2: ROLLBACK
-- ==================================

BEGIN;

UPDATE public.p3_incidents
SET status = 'Resolved'
WHERE incident_id = 102;

-- Confirm temporary change
SELECT incident_id, incident_title, status
FROM public.p3_incidents
WHERE incident_id = 102;

ROLLBACK;

-- Confirm original status restored
SELECT incident_id, incident_title, status
FROM public.p3_incidents
WHERE incident_id = 102;
