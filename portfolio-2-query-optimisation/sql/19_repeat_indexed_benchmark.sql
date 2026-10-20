
-- MIT 8103 - Portfolio 2
-- Step 4D.6C: Repeated indexed benchmark measurements
-- Database: theoscyba_portfolio2_lab
-- Run this same statement three times separately

EXPLAIN (ANALYZE, BUFFERS)
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
