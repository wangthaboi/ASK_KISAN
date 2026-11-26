-- ============================================================================
-- ASK KISAN: Reference Seed Data & Application Settings for Supabase
-- ============================================================================
-- This script safely seeds all initial reference tables and configuration flags.
-- It is fully idempotent and safe to run multiple times (uses ON CONFLICT DO NOTHING).
-- ============================================================================

-- 1. Application Runtime Settings (Dynamic LLM Fallback Flags)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS app_settings (
    key VARCHAR(64) PRIMARY KEY,
    value VARCHAR(255) NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO app_settings (key, value, description) VALUES
('enable_groq_fallback', 'true', 'Enable automatic fallback to Groq when Gemini rate limits or credits are exhausted'),
('primary_llm_provider', 'gemini', 'Primary LLM provider to use for chat and advisories (gemini or groq)')
ON CONFLICT (key) DO NOTHING;


-- 2. User Tiers & Quota Configurations
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_tiers (
    user_type VARCHAR(50) PRIMARY KEY,
    daily_token_limit INT NOT NULL,
    max_history_messages INT NOT NULL DEFAULT 6,
    description TEXT
);

INSERT INTO user_tiers (user_type, daily_token_limit, max_history_messages, description) VALUES
('Free', 10000, 6, 'Free plan with 10k daily tokens and 3-turn memory (~6 messages)'),
('Pro', 50000, 10, 'Pro farmer plan with 50k daily tokens and 5-turn memory (~10 messages)'),
('Ultra', 200000, 16, 'Ultra farmer plan with 200k daily tokens and 8-turn memory (~16 messages)'),
('FPOHead', 500000, 20, 'FPO Lead plan with 500k daily tokens and 10-turn memory (~20 messages)')
ON CONFLICT (user_type) DO NOTHING;


-- 3. Advisory Categories
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS advisory_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

INSERT INTO advisory_categories (category_name, description) VALUES
('Weather', 'Weather-related advisories'),
('Irrigation', 'Water management recommendations'),
('Pest', 'Pest management advisories'),
('Disease', 'Disease management advisories'),
('Nutrition', 'Plant nutrient deficiency advisories'),
('Fertilizer', 'Fertilizer recommendations'),
('Organic Practice', 'Organic farming recommendations'),
('Cultural Practice', 'Good agricultural practices'),
('Harvest', 'Harvest recommendations'),
('Post-Harvest', 'Storage and post-harvest handling'),
('General', 'General crop advice')
ON CONFLICT (category_name) DO NOTHING;


-- 4. Crop Growth Stages
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS crop_stages (
    stage_id SERIAL PRIMARY KEY,
    stage_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

INSERT INTO crop_stages (stage_name, description) VALUES
('Pre-sowing', 'Before sowing'),
('Seed Treatment', 'Seed preparation'),
('Nursery', 'Nursery stage'),
('Sowing', 'Crop sowing'),
('Germination', 'Seed germination'),
('Seedling', 'Young seedling stage'),
('Vegetative', 'Vegetative growth'),
('Tillering', 'Tillering stage'),
('Flowering', 'Flower initiation'),
('Fruiting', 'Fruit development'),
('Pod Formation', 'Pod development'),
('Grain Filling', 'Grain filling stage'),
('Maturity', 'Crop maturity'),
('Harvest', 'Harvest stage'),
('Post-Harvest', 'After harvesting'),
('Any', 'Applicable to any stage')
ON CONFLICT (stage_name) DO NOTHING;


-- 5. Trigger Types
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS trigger_types (
    trigger_type_id SERIAL PRIMARY KEY,
    trigger_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

INSERT INTO trigger_types (trigger_name, description) VALUES
('Crop Stage', 'Triggered by crop growth stage'),
('Weather', 'Triggered by weather conditions'),
('Pest', 'Triggered by pest occurrence'),
('Disease', 'Triggered by disease symptoms'),
('Nutrient Deficiency', 'Triggered by nutrient deficiency'),
('Farmer Query', 'General farmer question'),
('Routine', 'Routine scheduled advisory'),
('General', 'General advisory')
ON CONFLICT (trigger_name) DO NOTHING;


-- 6. Cropping Seasons
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS seasons (
    season_id SERIAL PRIMARY KEY,
    season_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

INSERT INTO seasons (season_name, description) VALUES
('Kharif', 'Monsoon cropping season'),
('Rabi', 'Winter cropping season'),
('Zaid', 'Summer cropping season'),
('Perennial', 'Applicable throughout the year'),
('All Seasons', 'Applicable in all seasons')
ON CONFLICT (season_name) DO NOTHING;


-- 7. Districts
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS districts (
    district_id SERIAL PRIMARY KEY,
    state_name VARCHAR(100),
    district_name VARCHAR(100) NOT NULL,
    UNIQUE(state_name, district_name)
);

INSERT INTO districts (state_name, district_name) VALUES
('Sikkim', 'East Sikkim'),
('Sikkim', 'West Sikkim'),
('Sikkim', 'North Sikkim'),
('Sikkim', 'South Sikkim'),
('West Bengal', 'Darjeeling'),
('West Bengal', 'Kalimpong')
ON CONFLICT (state_name, district_name) DO NOTHING;

