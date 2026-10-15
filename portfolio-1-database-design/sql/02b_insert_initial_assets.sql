
INSERT INTO assets (
    client_id,
    asset_name,
    asset_type,
    ip_address,
    operating_system
)
SELECT
    c.client_id,
    v.asset_name,
    v.asset_type,
    v.ip_address::INET,
    v.operating_system
FROM (
    VALUES
        (
            'PaySecure Fintech Ltd',
            'Payment Application Server',
            'Server',
            '192.0.2.10',
            'Ubuntu Linux'
        ),
        (
            'PaySecure Fintech Ltd',
            'Core Database Server',
            'Server',
            '192.0.2.11',
            'Ubuntu Linux'
        ),
        (
            'MedTrust Hospital',
            'Patient Records Server',
            'Server',
            '192.0.2.20',
            'Windows Server'
        ),
        (
            'MedTrust Hospital',
            'Reception Laptop',
            'Laptop',
            '192.0.2.21',
            'Windows 11'
        ),
        (
            'ShopEase Nigeria Ltd',
            'E-commerce Web Server',
            'Server',
            '192.0.2.30',
            'Ubuntu Linux'
        ),
        (
            'ShopEase Nigeria Ltd',
            'Inventory Server',
            'Server',
            '192.0.2.31',
            'Windows Server'
        )
) AS v (
    client_name,
    asset_name,
    asset_type,
    ip_address,
    operating_system
)
JOIN clients AS c
    ON c.client_name = v.client_name;
