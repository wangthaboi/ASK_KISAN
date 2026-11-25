-- ========================================================================
-- ASK_KISAN: Supabase (PostgreSQL) Schema & Initial Seed Data
-- ========================================================================

-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- 1. Crops Table
CREATE TABLE IF NOT EXISTS crops (
    crop_id SERIAL PRIMARY KEY,
    crop_name VARCHAR(100) NOT NULL,
    crop_category VARCHAR(100),
    primary_region VARCHAR(100),
    scientific_name VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Advisory Reference Tables
CREATE TABLE IF NOT EXISTS advisory_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS crop_stages (
    stage_id SERIAL PRIMARY KEY,
    stage_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS trigger_types (
    trigger_type_id SERIAL PRIMARY KEY,
    trigger_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS seasons (
    season_id SERIAL PRIMARY KEY,
    season_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS districts (
    district_id SERIAL PRIMARY KEY,
    state_name VARCHAR(100),
    district_name VARCHAR(100) NOT NULL,
    UNIQUE(state_name, district_name)
);

-- 3. Crop Production Guides
CREATE TABLE IF NOT EXISTS crop_production_guides (
    guide_id SERIAL PRIMARY KEY,
    crop_id INT NOT NULL REFERENCES crops(crop_id) ON DELETE CASCADE,
    season TEXT,
    soil_requirements TEXT,
    seed_rate TEXT,
    sowing_period TEXT,
    irrigation_requirements TEXT,
    fertilizer_recommendations TEXT,
    harvesting_guidelines TEXT
);

CREATE TABLE IF NOT EXISTS crop_guides (
    guide_id SERIAL PRIMARY KEY,
    crop_id INT NOT NULL REFERENCES crops(crop_id) ON DELETE CASCADE,
    season VARCHAR(100),
    soil_requirements TEXT,
    seed_rate TEXT,
    sowing_period TEXT,
    irrigation_requirements TEXT,
    fertilizer_recommendations TEXT,
    harvesting_guidelines TEXT,
    source VARCHAR(255),
    last_updated DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Crop Advisory
CREATE TABLE IF NOT EXISTS crop_advisory (
    advisory_id SERIAL PRIMARY KEY,
    crop_id INT NOT NULL REFERENCES crops(crop_id) ON DELETE CASCADE,
    category_id INT NOT NULL REFERENCES advisory_categories(category_id),
    stage_id INT REFERENCES crop_stages(stage_id),
    trigger_type_id INT NOT NULL REFERENCES trigger_types(trigger_type_id),
    trigger_condition VARCHAR(255) NOT NULL,
    recommendation TEXT NOT NULL,
    district_id INT REFERENCES districts(district_id),
    season_id INT REFERENCES seasons(season_id),
    priority VARCHAR(20) DEFAULT 'Medium',
    advisory_type VARCHAR(50) DEFAULT 'Informational',
    source VARCHAR(255),
    valid_from DATE,
    valid_until DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_advisory_crop ON crop_advisory(crop_id);
CREATE INDEX IF NOT EXISTS idx_advisory_category ON crop_advisory(category_id);
CREATE INDEX IF NOT EXISTS idx_advisory_stage ON crop_advisory(stage_id);
CREATE INDEX IF NOT EXISTS idx_advisory_trigger ON crop_advisory(trigger_type_id);
CREATE INDEX IF NOT EXISTS idx_advisory_district ON crop_advisory(district_id);
CREATE INDEX IF NOT EXISTS idx_advisory_season ON crop_advisory(season_id);

-- 5. Government Schemes
CREATE TABLE IF NOT EXISTS government_schemes (
    scheme_id SERIAL PRIMARY KEY,
    scheme_name VARCHAR(255) NOT NULL,
    short_name VARCHAR(50),
    annual_benefit DECIMAL(10,2),
    installment_amount DECIMAL(10,2),
    installments_per_year INT,
    eligibility TEXT,
    exclusions TEXT,
    required_documents TEXT,
    registration_steps TEXT,
    ekyc_methods TEXT,
    common_errors TEXT,
    status_messages TEXT,
    helplines TEXT,
    official_website VARCHAR(255),
    scheme_type VARCHAR(100),
    interest_rate_info TEXT,
    loan_limit_info TEXT,
    benefits TEXT,
    coverage_details TEXT,
    scheme_level VARCHAR(20) DEFAULT 'Central',
    target_sector VARCHAR(100),
    scheme_category VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS scheme_state_contacts (
    contact_id SERIAL PRIMARY KEY,
    scheme_id INT NOT NULL REFERENCES government_schemes(scheme_id) ON DELETE CASCADE,
    state_name VARCHAR(100) NOT NULL,
    department_name VARCHAR(255),
    contact_person VARCHAR(255),
    phone_number VARCHAR(50),
    email VARCHAR(255),
    website VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS scheme_faqs (
    faq_id SERIAL PRIMARY KEY,
    scheme_id INT REFERENCES government_schemes(scheme_id) ON DELETE CASCADE,
    scheme_name VARCHAR(100),
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    category VARCHAR(100),
    keywords TEXT,
    language VARCHAR(50) DEFAULT 'english',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. Derived Vector Embeddings Table (Search Layer)
CREATE TABLE IF NOT EXISTS vector_embeddings (
    id BIGSERIAL PRIMARY KEY,
    source_table VARCHAR(100) NOT NULL,
    source_id INT NOT NULL,
    content TEXT NOT NULL,
    content_hash CHAR(64),
    vector JSONB,
    embedding_model VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_vector_source ON vector_embeddings(source_table, source_id);

-- ========================================================================
-- Initial Reference Seed Data
-- ========================================================================

INSERT INTO advisory_categories (category_name, description) VALUES
('Weather','Weather-related advisories'),
('Irrigation','Water management recommendations'),
('Pest','Pest management advisories'),
('Disease','Disease management advisories'),
('Nutrition','Plant nutrient deficiency advisories'),
('Fertilizer','Fertilizer recommendations'),
('Organic Practice','Organic farming recommendations'),
('Cultural Practice','Good agricultural practices'),
('Harvest','Harvest recommendations'),
('Post-Harvest','Storage and post-harvest handling'),
('General','General crop advice')
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO crop_stages (stage_name, description) VALUES
('Pre-sowing','Before sowing'),
('Seed Treatment','Seed preparation'),
('Nursery','Nursery stage'),
('Sowing','Crop sowing'),
('Germination','Seed germination'),
('Seedling','Young seedling stage'),
('Vegetative','Vegetative growth'),
('Tillering','Tillering stage'),
('Flowering','Flower initiation'),
('Fruiting','Fruit development'),
('Pod Formation','Pod development'),
('Grain Filling','Grain filling stage'),
('Maturity','Crop maturity'),
('Harvest','Harvest stage'),
('Post-Harvest','After harvesting'),
('Any','Applicable to any stage')
ON CONFLICT (stage_name) DO NOTHING;

INSERT INTO trigger_types (trigger_name, description) VALUES
('Crop Stage','Triggered by crop growth stage'),
('Weather','Triggered by weather conditions'),
('Pest','Triggered by pest occurrence'),
('Disease','Triggered by disease symptoms'),
('Nutrient Deficiency','Triggered by nutrient deficiency'),
('Farmer Query','General farmer question'),
('Routine','Routine scheduled advisory'),
('General','General advisory')
ON CONFLICT (trigger_name) DO NOTHING;

INSERT INTO seasons (season_name, description) VALUES
('Kharif','Monsoon cropping season'),
('Rabi','Winter cropping season'),
('Zaid','Summer cropping season'),
('Perennial','Applicable throughout the year'),
('All Seasons','Applicable in all seasons')
ON CONFLICT (season_name) DO NOTHING;

INSERT INTO districts (state_name, district_name) VALUES
('Sikkim','East Sikkim'),
('Sikkim','West Sikkim'),
('Sikkim','North Sikkim'),
('Sikkim','South Sikkim'),
('West Bengal','Darjeeling'),
('West Bengal','Kalimpong')
ON CONFLICT (state_name, district_name) DO NOTHING;
