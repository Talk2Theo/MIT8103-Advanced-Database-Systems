
-- MIT 8103 - Advanced Database Systems
-- Portfolio 2 - Step 4D.10C
-- Add reporting indexes to the INSERT test table
--
-- Database: theoscyba_portfolio2_lab
-- Do NOT modify the baseline table.

DO $$
BEGIN

    -- 1. Verify the laboratory database.
    IF current_database() <> 'theoscyba_portfolio2_lab' THEN
        RAISE EXCEPTION
            'Wrong database. Stop the experiment.';
    END IF;

    -- 2. Verify that both test tables exist.
    IF to_regclass('public.vuln_insert_baseline') IS NULL
       OR to_regclass('public.vuln_insert_indexed') IS NULL THEN
        RAISE EXCEPTION
            'INSERT benchmark tables are missing.';
    END IF;

    -- 3. Both tables must still be empty.
    IF (SELECT COUNT(*) FROM public.vuln_insert_baseline) <> 0
       OR (SELECT COUNT(*) FROM public.vuln_insert_indexed) <> 0 THEN
        RAISE EXCEPTION
            'Expected both INSERT test tables to be empty.';
    END IF;

    -- 4. Each table must initially have one index.
    IF (
        SELECT COUNT(*)
        FROM pg_indexes
        WHERE schemaname = 'public'
          AND tablename = 'vuln_insert_baseline'
    ) <> 1
    OR (
        SELECT COUNT(*)
        FROM pg_indexes
        WHERE schemaname = 'public'
          AND tablename = 'vuln_insert_indexed'
    ) <> 1 THEN
        RAISE EXCEPTION
            'Unexpected existing index count. Stop.';
    END IF;

    -- Index 1: Composite filtering index.
    CREATE INDEX idx_vuln_insert_severity_status
    ON public.vuln_insert_indexed
    USING btree (
        severity,
        vulnerability_status
    );

    -- Index 2: Ordered partial index.
    CREATE INDEX idx_vuln_insert_priority_order
    ON public.vuln_insert_indexed
    USING btree (
        cvss_score DESC NULLS LAST,
        vulnerability_id ASC
    )
    WHERE severity IN ('Critical', 'High')
      AND vulnerability_status IN ('Open', 'In Progress');

    -- Index 3: Covering partial index.
    CREATE INDEX idx_vuln_insert_priority_covering
    ON public.vuln_insert_indexed
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

    RAISE NOTICE
        'Three secondary indexes created successfully.';

END
$$;
