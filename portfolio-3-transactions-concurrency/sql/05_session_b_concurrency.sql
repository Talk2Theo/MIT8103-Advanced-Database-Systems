
-- Portfolio 3 - Session B
-- Start a READ COMMITTED transaction

BEGIN ISOLATION LEVEL READ COMMITTED;

SELECT
    incident_id,
    assigned_analyst
FROM public.p3_incidents
WHERE incident_id = 103;
