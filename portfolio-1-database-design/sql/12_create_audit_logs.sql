
CREATE TABLE audit_logs (
    audit_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    actor_analyst_id INTEGER,

    action_type VARCHAR(10) NOT NULL,
    affected_table VARCHAR(50) NOT NULL,
    affected_record_id BIGINT NOT NULL,

    old_data JSONB,
    new_data JSONB,

    action_details TEXT,

    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_analyst
        FOREIGN KEY (actor_analyst_id)
        REFERENCES analysts(analyst_id),

    CONSTRAINT chk_audit_action_type
        CHECK (
            action_type IN ('INSERT', 'UPDATE', 'DELETE')
        ),

    CONSTRAINT chk_audit_affected_table
        CHECK (
            affected_table IN (
                'clients',
                'assets',
                'analysts',
                'incidents',
                'vulnerabilities',
                'remediation_activities'
            )
        ),

    CONSTRAINT chk_audit_record_id
        CHECK (affected_record_id > 0)
);
