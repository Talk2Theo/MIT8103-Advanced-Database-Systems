
CREATE TABLE incident_assignments (
    assignment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    incident_id INTEGER NOT NULL,
    analyst_id INTEGER NOT NULL,
    assigned_by_analyst_id INTEGER,

    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    unassigned_at TIMESTAMPTZ,

    assignment_reason TEXT,

    CONSTRAINT fk_assignment_incident
        FOREIGN KEY (incident_id)
        REFERENCES incidents(incident_id),

    CONSTRAINT fk_assignment_analyst
        FOREIGN KEY (analyst_id)
        REFERENCES analysts(analyst_id),

    CONSTRAINT fk_assignment_author
        FOREIGN KEY (assigned_by_analyst_id)
        REFERENCES analysts(analyst_id),

    CONSTRAINT chk_assignment_dates
        CHECK (
            unassigned_at IS NULL
            OR unassigned_at >= assigned_at
        )
);

CREATE UNIQUE INDEX uq_active_incident_assignment
ON incident_assignments (incident_id)
WHERE unassigned_at IS NULL;
