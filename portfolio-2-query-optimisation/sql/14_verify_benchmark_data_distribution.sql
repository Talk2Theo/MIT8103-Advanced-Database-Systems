
-- MIT 8103 - Portfolio 2
-- Step 4D.4: Verify benchmark data distribution
-- Read-only query

SELECT
    severity,
    vulnerability_status,
    COUNT(*) AS vulnerability_count,

    CASE
        WHEN severity IN ('Critical', 'High')
         AND vulnerability_status IN ('Open', 'In Progress')
        THEN 'Yes'
        ELSE 'No'
    END AS matches_high_priority_filter

FROM public.vulnerabilities_benchmark

GROUP BY
    severity,
    vulnerability_status

ORDER BY
    severity,
    vulnerability_status;
