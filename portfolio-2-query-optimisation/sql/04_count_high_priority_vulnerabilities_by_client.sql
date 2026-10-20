
-- Portfolio 2: Count high-priority vulnerabilities
-- for each affected client organisation
-- Read-only query

SELECT
    c.client_name,
    COUNT(*) AS high_priority_vulnerability_count

FROM public.vulnerabilities AS v

INNER JOIN public.assets AS a
    ON v.asset_id = a.asset_id

INNER JOIN public.clients AS c
    ON a.client_id = c.client_id

WHERE v.severity IN ('Critical', 'High')
  AND v.vulnerability_status IN ('Open', 'In Progress')

GROUP BY
    c.client_id,
    c.client_name

ORDER BY
    high_priority_vulnerability_count DESC,
    c.client_name ASC;
