
-- MIT 8103 - Advanced Database Systems
-- Portfolio 2 - Step 4D.10A
-- Measure benchmark table and index storage
-- READ-ONLY QUERY

SELECT
    current_database() AS database_name,

    pg_size_pretty(
        pg_table_size(
            'public.vulnerabilities_benchmark'
        )
    ) AS table_storage,

    pg_size_pretty(
        pg_indexes_size(
            'public.vulnerabilities_benchmark'
        )
    ) AS total_index_storage,

    pg_size_pretty(
        pg_total_relation_size(
            'public.vulnerabilities_benchmark'
        )
    ) AS overall_storage,

    ROUND(
        100.0 *
        pg_indexes_size(
            'public.vulnerabilities_benchmark'
        ) /
        NULLIF(
            pg_total_relation_size(
                'public.vulnerabilities_benchmark'
            ),
            0
        ),
        2
    ) AS index_percentage_of_total;
