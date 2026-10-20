
-- Step 4D.10B: Verify both INSERT test tables
-- Expected: 0 rows and 1 index for each table

SELECT
    'vuln_insert_baseline' AS table_name,

    (
        SELECT COUNT(*)
        FROM public.vuln_insert_baseline
    ) AS record_count,

    (
        SELECT COUNT(*)
        FROM pg_indexes
        WHERE schemaname = 'public'
          AND tablename = 'vuln_insert_baseline'
    ) AS index_count

UNION ALL

SELECT
    'vuln_insert_indexed' AS table_name,

    (
        SELECT COUNT(*)
        FROM public.vuln_insert_indexed
    ) AS record_count,

    (
        SELECT COUNT(*)
        FROM pg_indexes
        WHERE schemaname = 'public'
          AND tablename = 'vuln_insert_indexed'
    ) AS index_count;
