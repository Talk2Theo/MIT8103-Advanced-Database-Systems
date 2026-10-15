WITH sample_vulnerabilities (
    client_name,
    asset_name,
    vulnerability_title,
    vulnerability_description,
    cve_id,
    cvss_score,
    severity,
    vulnerability_status,
    identified_at,
    remediated_at
) AS (
    VALUES
    (
        'PaySecure Fintech Ltd',
        'Core Database Server',
        'Outdated Database Software',
        'Database software requires a security update.',
        NULL,
        8.1,
        'High',
        'Open',
        CURRENT_TIMESTAMP - INTERVAL '10 days',
        NULL::TIMESTAMPTZ
    ),
    (
        'MedTrust Hospital',
        'Patient Records Server',
        'Missing Critical Security Updates',
        'Critical operating system updates were missing.',
        NULL,
        9.0,
        'Critical',
        'In Progress',
        CURRENT_TIMESTAMP - INTERVAL '8 days',
        NULL
    ),
    (
        'ShopEase Nigeria Ltd',
        'E-commerce Web Server',
        'Weak TLS Configuration',
        'Web server permits outdated TLS configurations.',
        NULL,
        6.5,
        'Medium',
        'Remediated',
        CURRENT_TIMESTAMP - INTERVAL '15 days',
        CURRENT_TIMESTAMP - INTERVAL '12 days'
    ),
    (
        'PaySecure Fintech Ltd',
        'Payment Application Server',
        'Exposed Administrative Interface',
        'Administrative interface is accessible from an untrusted network.',
        NULL,
        8.0,
        'High',
        'Risk Accepted',
        CURRENT_TIMESTAMP - INTERVAL '6 days',
        NULL
    )
)
INSERT INTO vulnerabilities (
    asset_id,
    vulnerability_title,
    vulnerability_description,
    cve_id,
    cvss_score,
    severity,
    vulnerability_status,
    identified_at,
    remediated_at
)
SELECT
    a.asset_id,
    s.vulnerability_title,
    s.vulnerability_description,
    s.cve_id,
    s.cvss_score,
    s.severity,
    s.vulnerability_status,
    s.identified_at,
    s.remediated_at
FROM sample_vulnerabilities AS s
JOIN clients AS c
    ON c.client_name = s.client_name
JOIN assets AS a
    ON a.client_id = c.client_id
   AND a.asset_name = s.asset_name;
