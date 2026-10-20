
-- MIT 8103 - Portfolio 3
-- Script 01: Set up the transaction laboratory
-- Execute ONLY in theoscyba_portfolio3_lab

DO $$
BEGIN
    IF current_database() <> 'theoscyba_portfolio3_lab' THEN
        RAISE EXCEPTION
            'Wrong database. Connect to theoscyba_portfolio3_lab.';
    END IF;
END;
$$;

CREATE TABLE public.p3_incidents (
    incident_id INTEGER PRIMARY KEY,
    incident_title VARCHAR(200) NOT NULL,
    severity VARCHAR(20) NOT NULL
        CHECK (severity IN ('Low', 'Medium', 'High', 'Critical')),
    status VARCHAR(30) NOT NULL
        CHECK (status IN ('Open', 'Investigating', 'Resolved')),
    assigned_analyst VARCHAR(100) NOT NULL
);

INSERT INTO public.p3_incidents
    (incident_id, incident_title, severity, status, assigned_analyst)
VALUES
    (101, 'Suspicious VPN Login', 'High', 'Open', 'Daniel'),
    (102, 'Malware Detected on Endpoint', 'Critical', 'Open', 'Amina'),
    (103, 'Phishing Email Investigation', 'Medium', 'Investigating', 'Tunde');

SELECT
    current_database() AS database_name,
    incident_id,
    incident_title,
    severity,
    status,
    assigned_analyst
FROM public.p3_incidents
ORDER BY incident_id;
