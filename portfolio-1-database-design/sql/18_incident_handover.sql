
SELECT
    COUNT(*) AS total_assignments,

    COUNT(*) FILTER (
        WHERE unassigned_at IS NULL
    ) AS active_assignments,

    COUNT(*) FILTER (
        WHERE unassigned_at IS NOT NULL
    ) AS ended_assignments

FROM incident_assignments;
