
-- MIT 8103 - Portfolio 2
-- Step 4D.3: Generate 200,000 fictional vulnerabilities
-- LAB DATABASE ONLY

DO $$
BEGIN

    -- Safety check 1: Verify the database
    IF current_database() <> 'theoscyba_portfolio2_lab' THEN
        RAISE EXCEPTION
            'Wrong database. Use theoscyba_portfolio2_lab.';
    END IF;

    -- Safety check 2: Prevent duplicate generation
    IF EXISTS (
        SELECT 1
        FROM public.vulnerabilities_benchmark
    ) THEN
        RAISE EXCEPTION
            'Benchmark table already contains records. Stop.';
    END IF;

    -- Generate exactly 200,000 synthetic records
    INSERT INTO public.vulnerabilities_benchmark (
        asset_id,
        vulnerability_title,
        severity,
        cvss_score,
        vulnerability_status,
        identified_at
    )

    WITH synthetic_rows AS (
        SELECT
            n,
            (n - 1) % 100 AS severity_bucket,
            ((n - 1) / 100) % 10 AS status_bucket
        FROM generate_series(1, 200000) AS g(n)
    )

    SELECT
        1 + ((n - 1) % 1000),

        'Synthetic Vulnerability ' || n,

        CASE
            WHEN severity_bucket < 2 THEN 'Critical'
            WHEN severity_bucket < 10 THEN 'High'
            WHEN severity_bucket < 50 THEN 'Medium'
            ELSE 'Low'
        END,

        CASE
            WHEN severity_bucket < 2
                THEN 9.0 + ((n % 10) * 0.1)
            WHEN severity_bucket < 10
                THEN 7.0 + ((n % 10) * 0.1)
            WHEN severity_bucket < 50
                THEN 4.0 + ((n % 10) * 0.1)
            ELSE 2.0 + ((n % 10) * 0.1)
        END,

        CASE
            WHEN status_bucket = 0 THEN 'Open'
            WHEN status_bucket = 1 THEN 'In Progress'
            WHEN status_bucket < 6 THEN 'Remediated'
            ELSE 'Risk Accepted'
        END,

        TIMESTAMPTZ '2026-01-01 00:00:00+00'
            + ((n % 365) * INTERVAL '1 day')

    FROM synthetic_rows;

END
$$;
