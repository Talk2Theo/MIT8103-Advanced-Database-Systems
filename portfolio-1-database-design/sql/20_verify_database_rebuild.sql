
-- MIT 8103 - Advanced Database Systems
-- Theoscyba Security Services
--
-- Step 3AG.1: Final Database Verification
-- Target database: theoscyba_rebuild_test
--
-- READ-ONLY QUERY

SELECT
    current_database() AS database_name,

    (
        SELECT COUNT(*)
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_type = 'BASE TABLE'
    ) AS total_tables,

    (
        SELECT COUNT(*)
        FROM pg_constraint AS con
        JOIN pg_namespace AS ns
            ON ns.oid = con.connamespace
        WHERE con.contype = 'f'
          AND ns.nspname = 'public'
    ) AS total_foreign_keys,

    (
        SELECT COUNT(*)
        FROM clients
    ) AS clients,

    (
        SELECT COUNT(*)
        FROM assets
    ) AS assets,

    (
        SELECT COUNT(*)
        FROM analysts
    ) AS analysts,

    (
        SELECT COUNT(*)
        FROM incidents
    ) AS incidents,

    (
        SELECT COUNT(*)
        FROM vulnerabilities
    ) AS vulnerabilities,

    (
        SELECT COUNT(*)
        FROM remediation_activities
    ) AS remediations,

    (
        SELECT COUNT(*)
        FROM audit_logs
    ) AS audit_logs,

    (
        SELECT COUNT(*)
        FROM incident_assignments
    ) AS assignment_history,

    (
        SELECT COUNT(*)
        FROM incident_assignments
        WHERE unassigned_at IS NULL
    ) AS active_assignments,

    (
        SELECT COUNT(*)
        FROM incident_assignments
        WHERE unassigned_at IS NOT NULL
    ) AS ended_assignments;



SELECT
    EXISTS (
        SELECT 1
        FROM pg_trigger
        WHERE tgrelid = 'public.vulnerabilities'::regclass
          AND tgname = 'trg_audit_vulnerability_updates'
          AND tgenabled = 'O'
          AND NOT tgisinternal
    ) AS audit_trigger_enabled,

    EXISTS (
        SELECT 1
        FROM pg_indexes
        WHERE schemaname = 'public'
          AND tablename = 'incident_assignments'
          AND indexname = 'uq_active_incident_assignment'
          AND indexdef ILIKE '%UNIQUE INDEX%'
          AND indexdef ILIKE '%unassigned_at IS NULL%'
    ) AS partial_unique_index_exists;



SELECT
    i.incident_title,

    COALESCE(current_an.full_name, 'Unassigned')
        AS current_analyst,

    COALESCE(active_an.full_name, 'Unassigned')
        AS active_history_analyst,

    CASE
        WHEN i.assigned_analyst_id
             IS NOT DISTINCT FROM ia.analyst_id
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS verification_result

FROM incidents AS i

LEFT JOIN analysts AS current_an
    ON i.assigned_analyst_id = current_an.analyst_id

LEFT JOIN incident_assignments AS ia
    ON ia.incident_id = i.incident_id
   AND ia.unassigned_at IS NULL

LEFT JOIN analysts AS active_an
    ON ia.analyst_id = active_an.analyst_id

ORDER BY i.incident_id;
