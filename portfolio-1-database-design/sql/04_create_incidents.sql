CREATE TABLE incidents (
    incident_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    asset_id INTEGER NOT NULL,
    assigned_analyst_id INTEGER,

    incident_title VARCHAR(200) NOT NULL,
    incident_description TEXT,

    incident_type VARCHAR(50) NOT NULL,
    severity VARCHAR(20) NOT NULL,
    incident_status VARCHAR(20) NOT NULL DEFAULT 'Open',

    detected_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMPTZ,

    CONSTRAINT fk_incident_asset
        FOREIGN KEY (asset_id)
        REFERENCES assets(asset_id),

    CONSTRAINT fk_incident_analyst
        FOREIGN KEY (assigned_analyst_id)
        REFERENCES analysts(analyst_id),

    CONSTRAINT chk_incident_severity
        CHECK (
            severity IN ('Low', 'Medium', 'High', 'Critical')
        ),

    CONSTRAINT chk_incident_status
        CHECK (
            incident_status IN (
                'Open',
                'Investigating',
                'Resolved',
                'Closed'
            )
        ),

    CONSTRAINT chk_incident_dates
        CHECK (
            resolved_at IS NULL
            OR resolved_at >= detected_at
        )
);
