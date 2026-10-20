
-- MIT 8103 - Advanced Database Systems
-- Portfolio 2 - Step 4D.8G
-- Inspect visibility statistics before covering-index test
-- READ-ONLY QUERY

SELECT
    current_database() AS database_name,
    c.relname AS table_name,
    c.reltuples::bigint AS estimated_rows,
    c.relpages AS estimated_table_pages,
    c.relallvisible AS estimated_all_visible_pages,

    ROUND(
        100.0 * c.relallvisible
        / NULLIF(c.relpages, 0),
        2
    ) AS estimated_all_visible_percentage

FROM pg_class AS c

JOIN pg_namespace AS n
    ON n.oid = c.relnamespace

WHERE n.nspname = 'public'
  AND c.relname = 'vulnerabilities_benchmark'
  AND c.relkind = 'r';
