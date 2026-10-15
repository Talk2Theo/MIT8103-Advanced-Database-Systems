
INSERT INTO incident_assignments (
    incident_id,
    analyst_id,
    assignment_reason
)
SELECT
    i.incident_id,
    an.analyst_id,
    'Intentional duplicate assignment test'
FROM incidents AS i
JOIN assets AS a
    ON i.asset_id = a.asset_id
JOIN clients AS c
    ON a.client_id = c.client_id
JOIN analysts AS an
    ON an.email = 'amina.yusuf@theoscyba.example'
WHERE c.client_name = 'PaySecure Fintech Ltd'
  AND a.asset_name = 'Payment Application Server'
  AND i.incident_title = 'Suspicious VPN Sign-in';
