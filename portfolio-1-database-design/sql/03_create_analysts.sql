CREATE TABLE analysts (
    analyst_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE,
    analyst_role VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_analyst_role
        CHECK (
            analyst_role IN (
                'Security Analyst',
                'Vulnerability Analyst',
                'Security Manager',
                'InfoSec Engineer',
                'Security Engineer'
            )
        )
);
