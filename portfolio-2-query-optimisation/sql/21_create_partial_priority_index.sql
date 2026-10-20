
-- MIT 8103 - Advanced Database Systems
-- Portfolio 2: Query Processing and Optimisation
-- Step 4D.8A - Ordered Partial B-tree Index
--
-- Case Study: Theoscyba Security Services
-- Database: theoscyba_portfolio2_lab
-- Table: public.vulnerabilities_benchmark
--
-- Purpose:
-- Create a partial index for high-priority
-- vulnerabilities, ordered by CVSS score.
--
-- IMPORTANT:
-- This index was already created during
-- the original experiment.
-- Save this script for reproducibility.
-- DO NOT execute it again on the existing
-- benchmark database.

CREATE INDEX idx_vuln_benchmark_priority_order
ON public.vulnerabilities_benchmark
USING btree (
    cvss_score DESC NULLS LAST,
    vulnerability_id ASC
)
WHERE severity IN ('Critical', 'High')
  AND vulnerability_status IN ('Open', 'In Progress');
