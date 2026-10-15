
SELECT
    COALESCE(a.full_name, 'Unassigned') AS analyst,
    COUNT(*) AS total_incidents
FROM incidents AS i
LEFT JOIN analysts AS a
    ON i.assigned_analyst_id = a.analyst_id
GROUP BY a.analyst_id, a.full_name
ORDER BY analyst;
