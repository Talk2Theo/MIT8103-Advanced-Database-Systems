
-- MIT 8103 - Advanced Database Systems
-- Portfolio 2 - Step 4D.11A
-- Consolidated INSERT benchmark summary
--
-- Based on the three measured benchmark pairs.
-- READ-ONLY: no table changes.

WITH benchmark_results AS (

    SELECT *
    FROM (
        VALUES
            (
                1,
                'Baseline first',
                34.153::numeric,
                116.884::numeric,
                1976199::bigint,
                2869638::bigint
            ),
            (
                2,
                'Baseline first',
                30.337::numeric,
                127.934::numeric,
                1971341::bigint,
                2869061::bigint
            ),
            (
                3,
                'Indexed first',
                32.839::numeric,
                108.364::numeric,
                1971341::bigint,
                2869061::bigint
            )
    ) AS results (
        trial_number,
        test_order,
        baseline_ms,
        indexed_ms,
        baseline_wal_bytes,
        indexed_wal_bytes
    )
)

SELECT
    COUNT(*) AS benchmark_pairs,

    ROUND(
        AVG(baseline_ms), 3
    ) AS avg_baseline_ms,

    ROUND(
        AVG(indexed_ms), 3
    ) AS avg_indexed_ms,

    ROUND(
        AVG(indexed_ms - baseline_ms), 3
    ) AS avg_additional_ms,

    ROUND(
        AVG(indexed_ms)
        / NULLIF(AVG(baseline_ms), 0),
        2
    ) AS execution_time_ratio,

    ROUND(
        100 * (
            AVG(indexed_ms)
            - AVG(baseline_ms)
        ) / NULLIF(AVG(baseline_ms), 0),
        2
    ) AS indexed_time_increase_percent,

    ROUND(
        AVG(baseline_wal_bytes), 0
    ) AS avg_baseline_wal_bytes,

    ROUND(
        AVG(indexed_wal_bytes), 0
    ) AS avg_indexed_wal_bytes

FROM benchmark_results;
