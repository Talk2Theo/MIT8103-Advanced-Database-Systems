
-- Portfolio 3 - Session A
-- Analyst Daniel updates incident 103

BEGIN;

UPDATE public.p3_incidents
SET assigned_analyst = 'Daniel'
WHERE incident_id = 103
RETURNING incident_id, assigned_analyst;
