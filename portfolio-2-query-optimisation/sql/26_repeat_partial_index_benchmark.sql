
-- MIT 8103 - Portfolio 2
-- Step 4D.8F: Repeated partial-index performance
-- Run THREE times separately in the same transaction

EXPLAIN (ANALYZE, BUFFERS, SETTINGS)
SELECT
    vulnerability_id,
    vulnerability_title,
    severity,
    cvss_score,
    vulnerability_status
FROM public.vulnerabilities_benchmark
WHERE severity IN ('Critical', 'High')
  AND vulnerability_status IN ('Open', 'In Progress')
ORDER BY
    cvss_score DESC NULLS LAST,
    vulnerability_id ASC;
