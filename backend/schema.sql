-- BNPL Advisor PostgreSQL schema (mirrors SQLAlchemy models; for reference / manual setup)

CREATE TABLE IF NOT EXISTS sme_profile (
    id SERIAL PRIMARY KEY,
    business_name VARCHAR(255) NOT NULL,
    industry VARCHAR(128) NOT NULL,
    bumiputera_flag BOOLEAN NOT NULL DEFAULT FALSE,
    veteran_flag BOOLEAN NOT NULL DEFAULT FALSE,
    annual_revenue_rm DOUBLE PRECISION NOT NULL DEFAULT 0,
    employee_count INTEGER NOT NULL DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS financial_transaction (
    id SERIAL PRIMARY KEY,
    sme_id INTEGER NOT NULL REFERENCES sme_profile(id) ON DELETE CASCADE,
    txn_date DATE NOT NULL,
    amount_rm DOUBLE PRECISION NOT NULL,
    category VARCHAR(128) NOT NULL,
    description TEXT,
    is_expense BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS ix_financial_transaction_sme_id ON financial_transaction(sme_id);

CREATE TABLE IF NOT EXISTS cash_flow_snapshot (
    id SERIAL PRIMARY KEY,
    sme_id INTEGER NOT NULL REFERENCES sme_profile(id) ON DELETE CASCADE,
    snapshot_date DATE NOT NULL,
    current_ratio DOUBLE PRECISION NOT NULL,
    days_cash_on_hand DOUBLE PRECISION NOT NULL,
    burn_rate_monthly_rm DOUBLE PRECISION NOT NULL,
    revenue_mtd_rm DOUBLE PRECISION NOT NULL DEFAULT 0,
    expense_mtd_rm DOUBLE PRECISION NOT NULL DEFAULT 0,
    net_operating_cash_rm DOUBLE PRECISION NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS ix_cash_flow_snapshot_sme_id ON cash_flow_snapshot(sme_id);

CREATE TABLE IF NOT EXISTS bnpl_offer (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    provider VARCHAR(128) NOT NULL,
    max_amount_rm DOUBLE PRECISION NOT NULL DEFAULT 50000,
    max_tenure_months INTEGER NOT NULL DEFAULT 12,
    interest_free_days INTEGER NOT NULL DEFAULT 0,
    effective_monthly_rate_pct DOUBLE PRECISION NOT NULL DEFAULT 0,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS credit_line_offer (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    provider VARCHAR(128) NOT NULL,
    product_type VARCHAR(64) NOT NULL DEFAULT 'micro_credit',
    max_amount_rm DOUBLE PRECISION NOT NULL,
    annual_interest_rate_pct DOUBLE PRECISION NOT NULL,
    max_tenure_months INTEGER NOT NULL DEFAULT 36,
    approval_speed_days INTEGER NOT NULL DEFAULT 14,
    eligibility_summary TEXT
);

CREATE TABLE IF NOT EXISTS gov_financial_aid (
    id SERIAL PRIMARY KEY,
    scheme_name VARCHAR(255) NOT NULL,
    agency VARCHAR(128) NOT NULL,
    aid_type VARCHAR(64) NOT NULL,
    max_amount_rm DOUBLE PRECISION,
    interest_rate_label VARCHAR(128),
    tenure_months INTEGER,
    approval_speed_label VARCHAR(128) NOT NULL,
    requires_bumiputera BOOLEAN NOT NULL DEFAULT FALSE,
    requires_veteran BOOLEAN NOT NULL DEFAULT FALSE,
    industry_keywords TEXT,
    digitalisation_only BOOLEAN NOT NULL DEFAULT FALSE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS prediction_log (
    id SERIAL PRIMARY KEY,
    sme_id INTEGER NOT NULL REFERENCES sme_profile(id) ON DELETE CASCADE,
    request_payload JSONB NOT NULL,
    recommendation_type VARCHAR(32) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    explanation TEXT NOT NULL,
    cash_preserved_rm DOUBLE PRECISION NOT NULL DEFAULT 0,
    additional_cost_rm DOUBLE PRECISION NOT NULL DEFAULT 0,
    confidence DOUBLE PRECISION NOT NULL DEFAULT 0,
    shap_values JSONB,
    ml_probability DOUBLE PRECISION,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS ix_prediction_log_sme_id ON prediction_log(sme_id);
