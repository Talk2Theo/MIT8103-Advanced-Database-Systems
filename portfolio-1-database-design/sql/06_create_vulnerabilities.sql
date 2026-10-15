
CREATE TABLE vulnerabilities (
    vulnerability_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    asset_id INTEGER NOT NULL,

    vulnerability_title VARCHAR(200) NOT NULL,
    vulnerability_description TEXT,

    cve_id VARCHAR(20),
    cvss_score NUMERIC(3,1),

    severity VARCHAR(20) NOT NULL,
    vulnerability_status VARCHAR(30) NOT NULL DEFAULT 'Open',

    identified_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remediated_at TIMESTAMPTZ,

    CONSTRAINT fk_vulnerability_asset
        FOREIGN KEY (asset_id)
        REFERENCES assets(asset_id),

    CONSTRAINT chk_vulnerability_severity
        CHECK (
            severity IN ('Low', 'Medium', 'High', 'Critical')
        ),

    CONSTRAINT chk_vulnerability_status
        CHECK (
            vulnerability_status IN (
                'Open',
                'In Progress',
                'Remediated',
                'Risk Accepted'
            )
        ),

    CONSTRAINT chk_cvss_score
        CHECK (
            cvss_score BETWEEN 0.0 AND 10.0
        ),

    CONSTRAINT chk_vulnerability_dates
        CHECK (
            remediated_at IS NULL
            OR remediated_at >= identified_at
        )
);
