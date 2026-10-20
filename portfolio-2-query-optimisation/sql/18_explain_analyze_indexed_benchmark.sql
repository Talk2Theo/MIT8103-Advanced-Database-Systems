
-- MIT 8103 - Advanced Database Systems
-- Portfolio 2 - Step 4D.6B
-- Query performance after creating composite index
-- Database: theoscyba_portfolio2_lab
-- Benchmark records: 200,000

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
