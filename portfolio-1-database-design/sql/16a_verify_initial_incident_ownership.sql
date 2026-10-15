
SELECT
    i.incident_id,
    i.incident_title,
    COALESCE(an.full_name, 'Unassigned') AS current_analyst
FROM incidents AS i
LEFT JOIN analysts AS an
    ON i.assigned_analyst_id = an.analyst_id
ORDER BY i.incident_id;
