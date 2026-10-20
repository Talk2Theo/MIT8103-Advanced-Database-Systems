
-- MIT 8103 - Portfolio 3
-- Script 01: Transaction Laboratory Setup
-- Theoscyba Security Services
-- Expected total: 100 fictional incidents

-- Safety check: only use the Portfolio 3 database
DO $$
BEGIN
    IF current_database() <> 'theoscyba_portfolio3_lab' THEN
        RAISE EXCEPTION
            'Wrong database. Connect to theoscyba_portfolio3_lab.';
    END IF;
END;
$$;

-- Create incident table
CREATE TABLE IF NOT EXISTS public.p3_incidents (
    incident_id INTEGER PRIMARY KEY,
    incident_title VARCHAR(200) NOT NULL,
    severity VARCHAR(20) NOT NULL
        CHECK (severity IN ('Low', 'Medium', 'High', 'Critical')),
    status VARCHAR(30) NOT NULL
        CHECK (status IN ('Open', 'Investigating', 'Resolved')),
    assigned_analyst VARCHAR(100) NOT NULL
);

-- Preserve our three original incidents
INSERT INTO public.p3_incidents
    (incident_id, incident_title, severity, status, assigned_analyst)
VALUES
    (101, 'Suspicious VPN Login', 'High', 'Open', 'Daniel'),
    (102, 'Malware Detected on Endpoint', 'Critical', 'Open', 'Amina'),
    (103, 'Phishing Email Investigation', 'Medium', 'Investigating', 'Tunde')
ON CONFLICT (incident_id) DO NOTHING;

-- Generate 97 additional fictional incidents
INSERT INTO public.p3_incidents
    (incident_id, incident_title, severity, status, assigned_analyst)
SELECT
    id,
    (ARRAY[
        'Unauthorised VPN Connection',
        'Malware Detection',
        'Phishing Attempt',
        'Suspicious Login',
        'Endpoint Security Alert',
        'Brute Force Attempt',
        'Unpatched System Vulnerability',
        'Suspicious Network Traffic',
        'Credential Theft Attempt',
        'Unauthorised Privilege Escalation'
    ])[((id - 104) % 10) + 1]
        || ' - Case ' || id,
    (ARRAY['Low', 'Medium', 'High', 'Critical'])
        [((id - 104) % 4) + 1],
    (ARRAY['Open', 'Investigating', 'Resolved'])
        [((id - 104) % 3) + 1],
    (ARRAY['Daniel', 'Amina', 'Tunde'])
        [((id - 104) % 3) + 1]
FROM generate_series(104, 200) AS id
ON CONFLICT (incident_id) DO NOTHING;

-- Verify total number of incidents
SELECT COUNT(*) AS total_incidents
FROM public.p3_incidents;

-- Inspect the first 10 incidents
SELECT *
FROM public.p3_incidents
ORDER BY incident_id
LIMIT 10;

-- Check incident distribution
SELECT severity, COUNT(*) AS incident_count
FROM public.p3_incidents
GROUP BY severity
ORDER BY severity;
