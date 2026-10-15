
CREATE TABLE assets (
    asset_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id INTEGER NOT NULL,
    asset_name VARCHAR(150) NOT NULL,
    asset_type VARCHAR(50) NOT NULL,
    ip_address INET,
    operating_system VARCHAR(100),
    asset_status VARCHAR(20) NOT NULL DEFAULT 'Active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_assets_client
        FOREIGN KEY (client_id)
        REFERENCES clients(client_id),

    CONSTRAINT chk_asset_status
        CHECK (asset_status IN ('Active', 'Inactive', 'Retired')),

    CONSTRAINT uq_client_asset_name
        UNIQUE (client_id, asset_name)
);
