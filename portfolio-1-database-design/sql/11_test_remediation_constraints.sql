INSERT INTO remediation_activities (
    vulnerability_id,
    action_description
)
VALUES (
    99999999,
    'Test remediation for nonexistent vulnerability'
);

INSERT INTO remediation_activities (
    vulnerability_id,
    assigned_analyst_id,
    action_description
)
SELECT
    v.vulnerability_id,
    99999999,
    'Test invalid analyst assignment'
FROM vulnerabilities AS v
JOIN assets AS a
    ON v.asset_id = a.asset_id
JOIN clients AS c
    ON a.client_id = c.client_id
WHERE c.client_name = 'PaySecure Fintech Ltd'
  AND v.vulnerability_title = 'Outdated Database Software';

INSERT INTO remediation_activities (
    vulnerability_id,
    action_description,
    remediation_status
)
SELECT
    v.vulnerability_id,
    'Test invalid remediation status',
    'Awaiting Magic'
FROM vulnerabilities AS v
JOIN assets AS a
    ON v.asset_id = a.asset_id
JOIN clients AS c
    ON a.client_id = c.client_id
WHERE c.client_name = 'FOLM Nigeria Ltd'
  AND v.vulnerability_title = 'Missing Application Security Patches';

INSERT INTO remediation_activities (
    vulnerability_id,
    action_description,
    remediation_status,
    completed_at
)
SELECT
    v.vulnerability_id,
    'Test completion without timestamp',
    'Completed',
    NULL
FROM vulnerabilities AS v
JOIN assets AS a
    ON v.asset_id = a.asset_id
JOIN clients AS c
    ON a.client_id = c.client_id
WHERE c.client_name = 'MedTrust Hospital'
  AND v.vulnerability_title = 'Missing Critical Security Updates';
