
-- Portfolio 2: High-priority vulnerabilities
-- with affected assets and client organisations
-- Read-only query

SELECT
    c.client_name,
    a.asset_name,
    a.asset_type,
    v.vulnerability_id,
    v.vulnerability_title,
    v.severity,
    v.cvss_score,
    v.vulnerability_status
FROM public.vulnerabilities AS v

INNER JOIN public.assets AS a
    ON v.asset_id = a.asset_id

INNER JOIN public.clients AS c
    ON a.client_id = c.client_id

WHERE v.severity IN ('Critical', 'High')
  AND v.vulnerability_status IN ('Open', 'In Progress')

ORDER BY
    v.cvss_score DESC NULLS LAST,
    v.vulnerability_id ASC;
