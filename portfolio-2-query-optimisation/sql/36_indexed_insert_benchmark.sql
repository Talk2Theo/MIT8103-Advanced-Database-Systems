
-- MIT 8103 - Portfolio 2
-- Step 4D.10E
-- Indexed-table INSERT performance
-- Run ONCE inside the open transaction.

EXPLAIN (ANALYZE, BUFFERS, WAL)

INSERT INTO public.vuln_insert_indexed (
    asset_id,
    vulnerability_title,
    severity,
    cvss_score,
    vulnerability_status
)

SELECT
    (g % 10) + 1 AS asset_id,

    'Synthetic Vulnerability ' || g
        AS vulnerability_title,

    CASE
        WHEN g % 50 = 0 THEN 'Critical'
        WHEN g % 50 < 5 THEN 'High'
        WHEN g % 50 < 25 THEN 'Medium'
        ELSE 'Low'
    END AS severity,

    ((g % 101)::numeric / 10)::numeric(3,1)
        AS cvss_score,

    CASE
        WHEN g % 10 = 0 THEN 'Open'
        WHEN g % 10 = 1 THEN 'In Progress'
        WHEN g % 10 < 6 THEN 'Remediated'
        ELSE 'Risk Accepted'
    END AS vulnerability_status

FROM generate_series(1, 10000) AS g;
