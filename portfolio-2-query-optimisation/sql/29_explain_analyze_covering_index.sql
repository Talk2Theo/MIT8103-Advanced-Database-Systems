
-- MIT 8103 - Advanced Database Systems
-- Portfolio 2 - Step 4D.8I
-- Covering partial-index performance evaluation
-- Database: theoscyba_portfolio2_lab
-- Dataset: 200,000 fictional vulnerabilities
-- Read-only SELECT query

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
