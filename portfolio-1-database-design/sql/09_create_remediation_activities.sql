CREATE TABLE remediation_activities (
    remediation_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    vulnerability_id INTEGER NOT NULL,
    assigned_analyst_id INTEGER,

    action_description TEXT NOT NULL,

    remediation_status VARCHAR(20) NOT NULL DEFAULT 'Planned',

    planned_due_date DATE,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_remediation_vulnerability
        FOREIGN KEY (vulnerability_id)
        REFERENCES vulnerabilities(vulnerability_id),

    CONSTRAINT fk_remediation_analyst
        FOREIGN KEY (assigned_analyst_id)
        REFERENCES analysts(analyst_id),

    CONSTRAINT chk_remediation_status
        CHECK (
            remediation_status IN (
                'Planned',
                'In Progress',
                'Completed',
                'Cancelled'
            )
        ),

    CONSTRAINT chk_remediation_dates
        CHECK (
            completed_at IS NULL
            OR started_at IS NULL
            OR completed_at >= started_at
        ),

    CONSTRAINT chk_remediation_completion
        CHECK (
            (remediation_status = 'Completed'
             AND completed_at IS NOT NULL)
            OR
            (remediation_status <> 'Completed'
             AND completed_at IS NULL)
        )
);
