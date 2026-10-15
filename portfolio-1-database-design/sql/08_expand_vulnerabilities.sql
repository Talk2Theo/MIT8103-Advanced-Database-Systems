
-- MIT 8103 - Advanced Database Systems
-- Theoscyba Security Services
--
-- Script: 08_expand_vulnerabilities.sql
-- Purpose: Insert four fictional vulnerabilities
--          for assets with assigned IP addresses.
--
-- Target database: theoscyba_rebuild_test
--
-- Prerequisites:
-- 1. Six client records exist.
-- 2. Twelve asset records exist.
-- 3. The initial four vulnerabilities exist.
-- 4. Script 08a_insert_expansion_assets.sql
--    has already been executed.
--
-- Expected result:
-- Total vulnerabilities = 8
--
-- CVSS scores are illustrative coursework values.

WITH new_vulnerabilities (
    client_name,
    asset_name,
    vulnerability_title,
    vulnerability_description,
    cvss_score,
    severity,
    vulnerability_status
) AS (
    VALUES

    -- UnoTelos: Staff Onboarding Server
    (
        'UnoTelos Group',
        'Staff Onboarding Server',
        'Outdated Staff Onboarding Software',
        'The staff onboarding application uses a software component that requires security updates.',
        8.2,
        'High',
        'Open'
    ),

    -- UnoTelos: HR documents Server
    (
        'UnoTelos Group',
        'HR documents Server',
        'Exposed Administrative Management Service',
        'An administrative management service on the HR documents server is accessible from an untrusted network.',
        9.1,
        'Critical',
        'In Progress'
    ),

    -- Simeon Champ: Clients database Server
    (
        'Simeon Champ',
        'Clients database Server',
        'Weak Database Access Configuration',
        'Database access controls are insufficiently restrictive and require security hardening.',
        6.4,
        'Medium',
        'Open'
    ),

    -- FOLM Nigeria: Customer Contacts Server
    (
        'FOLM Nigeria Ltd',
        'Customer Contacts Server',
        'Missing Server Security Patches',
        'The customer contacts server is missing security patches required to address known software weaknesses.',
        7.8,
        'High',
        'Open'
    )
)

INSERT INTO vulnerabilities (
    asset_id,
    vulnerability_title,
    vulnerability_description,
    cvss_score,
    severity,
    vulnerability_status
)

SELECT
    a.asset_id,
    nv.vulnerability_title,
    nv.vulnerability_description,
    nv.cvss_score,
    nv.severity,
    nv.vulnerability_status

FROM new_vulnerabilities AS nv

JOIN clients AS c
    ON c.client_name = nv.client_name

JOIN assets AS a
    ON a.client_id = c.client_id
   AND a.asset_name = nv.asset_name

WHERE NOT EXISTS (
    SELECT 1
    FROM vulnerabilities AS v
    WHERE v.asset_id = a.asset_id
      AND v.vulnerability_title = nv.vulnerability_title
);
