
-- MIT 8103 - Advanced Database Systems
-- Theoscyba Security Services
--
-- Script: 08a_insert_expansion_assets.sql
-- Purpose: Insert six additional client assets
--          that have assigned IP addresses.
--
-- Target database: theoscyba_rebuild_test
--
-- Prerequisites:
-- 1. All six clients already exist.
-- 2. Six original assets already exist.
--
-- Expected result after execution:
-- Total assets = 12

WITH new_assets (
    client_name,
    asset_name,
    asset_type,
    ip_address,
    operating_system,
    asset_status
) AS (
    VALUES
    (
        'UnoTelos Group',
        'Staff Onboarding Server',
        'Server',
        '192.0.2.40',
        'Windows 10',
        'Active'
    ),
    (
        'UnoTelos Group',
        'HR documents Server',
        'Server',
        '192.0.2.41',
        'Redhat Linux',
        'Active'
    ),
    (
        'Simeon Champ',
        'Clients database Server',
        'Server',
        '192.0.2.50',
        'Ubuntu Linux',
        'Active'
    ),
    (
        'Simeon Champ',
        'CEO Laptop',
        'Laptop',
        '192.0.2.51',
        'Windows 11',
        'Active'
    ),
    (
        'FOLM Nigeria Ltd',
        'Customer Contacts Server',
        'Server',
        '192.0.2.60',
        'Ubuntu Linux',
        'Active'
    ),
    (
        'FOLM Nigeria Ltd',
        'Marketing Team Laptop',
        'Laptop',
        '192.0.2.61',
        'Redhat Linux',
        'Active'
    )
)
INSERT INTO assets (
    client_id,
    asset_name,
    asset_type,
    ip_address,
    operating_system,
    asset_status
)
SELECT
    c.client_id,
    na.asset_name,
    na.asset_type,
    na.ip_address::INET,
    na.operating_system,
    na.asset_status
FROM new_assets AS na
JOIN clients AS c
    ON c.client_name = na.client_name
ON CONFLICT (client_id, asset_name)
DO NOTHING;
