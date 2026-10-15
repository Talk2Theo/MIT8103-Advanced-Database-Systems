
SELECT
    i.incident_title,
    an.full_name AS analyst_name,
    ia.assigned_at,
    ia.unassigned_at,
    CASE
        WHEN ia.unassigned_at IS NULL THEN 'Active'
        ELSE 'Ended'
    END AS assignment_status
FROM incident_assignments AS ia
JOIN incidents AS i
    ON ia.incident_id = i.incident_id
JOIN analysts AS an
    ON ia.analyst_id = an.analyst_id
JOIN assets AS a
    ON i.asset_id = a.asset_id
JOIN clients AS c
    ON a.client_id = c.client_id
WHERE c.client_name = 'PaySecure Fintech Ltd'
  AND a.asset_name = 'Payment Application Server'
  AND i.incident_title = 'Suspicious VPN Sign-in'
ORDER BY ia.assigned_at, ia.assignment_id;


SELECT
    COUNT(*) AS total_assignments,
    COUNT(*) FILTER (
        WHERE unassigned_at IS NULL
    ) AS active_assignments,
    COUNT(*) FILTER (
        WHERE unassigned_at IS NOT NULL
    ) AS ended_assignments
FROM incident_assignments;


-- Step 3: Verify all current incident owners
-- against their active assignment history.

SELECT
    i.incident_title,

    COALESCE(current_an.full_name, 'Unassigned')
        AS current_analyst,

    COALESCE(history_an.full_name, 'Unassigned')
        AS active_history_analyst,

    CASE
        WHEN i.assigned_analyst_id
             IS NOT DISTINCT FROM ia.analyst_id
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS ownership_validation

FROM incidents AS i

LEFT JOIN analysts AS current_an
    ON i.assigned_analyst_id = current_an.analyst_id

LEFT JOIN incident_assignments AS ia
    ON ia.incident_id = i.incident_id
   AND ia.unassigned_at IS NULL

LEFT JOIN analysts AS history_an
    ON ia.analyst_id = history_an.analyst_id

ORDER BY i.incident_id;


-- Step 4: Verify no incident has
-- more than one active assignment.

SELECT
    incident_id,
    COUNT(*) AS active_assignment_count

FROM incident_assignments

WHERE unassigned_at IS NULL

GROUP BY incident_id

HAVING COUNT(*) > 1;
