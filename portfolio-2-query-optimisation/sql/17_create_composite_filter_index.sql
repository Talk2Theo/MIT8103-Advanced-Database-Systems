
-- MIT 8103 - Advanced Database Systems
-- Portfolio 2 - Step 4D.6A
-- Create the first composite filtering index
-- LAB DATABASE ONLY

DO $$
BEGIN

    -- Safety check: correct database
    IF current_database() <> 'theoscyba_portfolio2_lab' THEN
        RAISE EXCEPTION
            'Wrong database. Use theoscyba_portfolio2_lab.';
    END IF;

    -- Safety check: benchmark table has expected records
    IF (
        SELECT COUNT(*)
        FROM public.vulnerabilities_benchmark
    ) <> 200000 THEN
        RAISE EXCEPTION
            'Expected 200000 records. Index creation stopped.';
    END IF;

    -- Create a composite B-tree index
    CREATE INDEX idx_vuln_benchmark_severity_status
    ON public.vulnerabilities_benchmark
    USING btree (
        severity,
        vulnerability_status
    );

END
$$;
