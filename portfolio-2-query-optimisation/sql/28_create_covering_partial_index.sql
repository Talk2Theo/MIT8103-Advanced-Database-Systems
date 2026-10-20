
-- MIT 8103 - Advanced Database Systems
-- Portfolio 2 - Step 4D.8H
-- Create a covering partial B-tree index
-- LAB DATABASE ONLY

DO $$
BEGIN

    -- Safety check: correct laboratory database
    IF current_database() <> 'theoscyba_portfolio2_lab' THEN
        RAISE EXCEPTION
            'Wrong database. Use theoscyba_portfolio2_lab.';
    END IF;

    -- Safety check: verify benchmark row count
    IF (
        SELECT COUNT(*)
        FROM public.vulnerabilities_benchmark
    ) <> 200000 THEN
        RAISE EXCEPTION
            'Expected 200000 records. Operation stopped.';
    END IF;

    -- Create covering partial index
    CREATE INDEX idx_vuln_benchmark_priority_covering
    ON public.vulnerabilities_benchmark
    USING btree (
        cvss_score DESC NULLS LAST,
        vulnerability_id ASC
    )
    INCLUDE (
        vulnerability_title,
        severity,
        vulnerability_status
    )
    WHERE severity IN ('Critical', 'High')
      AND vulnerability_status IN ('Open', 'In Progress');

END
$$;
