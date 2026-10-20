-- MIT 8103 - Portfolio 2
-- Step 4C.8: EXPLAIN after ANALYZE
-- Read-only query

EXPLAIN
SELECT
    vulnerability_id,
    vulnerability_title,
    severity,
    cvss_score,
    vulnerability_status
FROM public.vulnerabilities
WHERE severity IN ('Critical', 'High')
  AND vulnerability_status IN ('Open', 'In Progress')
ORDER BY
    cvss_score DESC NULLS LAST,
    vulnerability_id ASC;
