
-- MIT 8103 - Portfolio 2
-- Step 4C.10: Actual execution after ANALYZE
-- Read-only SELECT query

EXPLAIN ANALYZE
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
