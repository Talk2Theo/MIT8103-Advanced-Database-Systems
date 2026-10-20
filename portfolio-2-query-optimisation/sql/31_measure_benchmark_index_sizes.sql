
-- MIT 8103 - Advanced Database Systems
-- Portfolio 2 - Step 4D.9
-- Measure storage usage of benchmark indexes
-- READ-ONLY QUERY

SELECT
    idx.indexrelid::regclass AS index_name,

    pg_size_pretty(
        pg_relation_size(idx.indexrelid)
    ) AS index_size,

    pg_relation_size(
        idx.indexrelid
    ) AS index_size_bytes

FROM pg_index AS idx

WHERE idx.indrelid =
    'public.vulnerabilities_benchmark'::regclass

ORDER BY
    pg_relation_size(idx.indexrelid) DESC;
