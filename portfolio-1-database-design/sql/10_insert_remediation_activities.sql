
-- MIT 8103 - Advanced Database Systems
-- Theoscyba Security Services
--
-- Script: 10_insert_remediation_activities.sql
-- Purpose: Insert seven remediation activities.
--
-- Target database: theoscyba_rebuild_test
--
-- Prerequisites:
-- 1. Six clients exist.
-- 2. Twelve assets exist.
-- 3. Five analysts exist.
-- 4. Eight vulnerabilities exist.
--
-- Expected result:
-- Seven remediation activities:
-- 4 Planned, 2 In Progress, 1 Completed.

WITH sample_remediations (
    client_name,
    asset_name,
    vulnerability_title,
    analyst_email,
    action_description,
    remediation_status,
    planned_due_date,
    started_at,
    completed_at
) AS (
    VALUES

    -- 1. PaySecure: Database upgrade
    (
        'PaySecure Fintech Ltd',
        'Core Database Server',
        'Outdated Database Software',
        'amina.yusuf@theoscyba.example',
        'Upgrade database software to a supported secure version.',
        'Planned',
        CURRENT_DATE + 7,
        NULL::TIMESTAMPTZ,
        NULL::TIMESTAMPTZ
    ),

    -- 2. MedTrust: Critical security patches
    (
        'MedTrust Hospital',
        'Patient Records Server',
        'Missing Critical Security Updates',
        'chineze.okafor@theoscyba.example',
        'Install critical operating system security patches.',
        'In Progress',
        CURRENT_DATE + 3,
        CURRENT_TIMESTAMP - INTERVAL '4 days',
        NULL
    ),

    -- 3. MedTrust: Patch verification
    (
        'MedTrust Hospital',
        'Patient Records Server',
        'Missing Critical Security Updates',
        'amina.yusuf@theoscyba.example',
        'Verify patch installation and perform a vulnerability rescan.',
        'Planned',
        CURRENT_DATE + 5,
        NULL,
        NULL
    ),

    -- 4. ShopEase: TLS security hardening
    (
        'ShopEase Nigeria Ltd',
        'E-commerce Web Server',
        'Weak TLS Configuration',
        'osayuki.fola@theoscyba.example',
        'Disable weak TLS settings and verify secure protocols.',
        'Completed',
        CURRENT_DATE - 12,
        CURRENT_TIMESTAMP - INTERVAL '14 days',
        CURRENT_TIMESTAMP - INTERVAL '12 days'
    ),

    -- 5. UnoTelos: Administrative management access
    (
        'UnoTelos Group',
        'HR documents Server',
        'Exposed Administrative Management Service',
        'akinola.emmanuel@theoscyba.example',
        'Restrict administrative management access on the HR documents Server using firewall rules and approved management networks.',
        'In Progress',
        CURRENT_DATE + 2,
        CURRENT_TIMESTAMP,
        NULL
    ),

    -- 6. Simeon Champ: Database access hardening
    (
        'Simeon Champ',
        'Clients database Server',
        'Weak Database Access Configuration',
        NULL,
        'Harden database access controls by reviewing permissions, restricting administrative connections and enforcing least privilege.',
        'Planned',
        CURRENT_DATE + 10,
        NULL,
        NULL
    ),

    -- 7. FOLM Nigeria: Server security patches
    (
        'FOLM Nigeria Ltd',
        'Customer Contacts Server',
        'Missing Server Security Patches',
        'james.abraham@theoscyba.example',
        'Install missing security patches on the Customer Contacts Server and verify system functionality after remediation.',
        'Planned',
        CURRENT_DATE + 6,
        NULL,
        NULL
    )
)

INSERT INTO remediation_activities (
    vulnerability_id,
    assigned_analyst_id,
    action_description,
    remediation_status,
    planned_due_date,
    started_at,
    completed_at
)

SELECT
    v.vulnerability_id,
    an.analyst_id,
    sr.action_description,
    sr.remediation_status,
    sr.planned_due_date,
    sr.started_at,
    sr.completed_at

FROM sample_remediations AS sr

JOIN clients AS c
    ON c.client_name = sr.client_name

JOIN assets AS a
    ON a.client_id = c.client_id
   AND a.asset_name = sr.asset_name

JOIN vulnerabilities AS v
    ON v.asset_id = a.asset_id
   AND v.vulnerability_title = sr.vulnerability_title

LEFT JOIN analysts AS an
    ON an.email = sr.analyst_email;
