CREATE DATABASE ASK_KISAN;
USE ASK_KISAN;
CREATE TABLE government_schemes (

    scheme_id INT AUTO_INCREMENT PRIMARY KEY,

    scheme_name VARCHAR(255),
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

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
SHOW TABLES; 
ALTER TABLE government_schemes
ADD COLUMN scheme_level ENUM('Central','State') NOT NULL DEFAULT 'Central',
ADD COLUMN target_sector VARCHAR(100) NULL;
CREATE TABLE scheme_state_contacts (
    contact_id INT AUTO_INCREMENT PRIMARY KEY,
    scheme_id INT NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    department_name VARCHAR(255),
    contact_person VARCHAR(255),
    phone_number VARCHAR(50),
    email VARCHAR(255),
    website VARCHAR(255),
    FOREIGN KEY (scheme_id)
        REFERENCES government_schemes(scheme_id)
);
SHOW CREATE TABLE government_schemes;
INSERT INTO government_schemes (
    scheme_name,
    short_name,
    annual_benefit,
    installment_amount,
    installments_per_year,
    eligibility,
    exclusions,
    required_documents,
    registration_steps,
    ekyc_methods,
    common_errors,
    status_messages,
    helplines,
    official_website,
    scheme_type,
    interest_rate_info,
    loan_limit_info,
    benefits,
    coverage_details,
    scheme_level,
    target_sector
)
VALUES (
    'Sub-Mission on Agricultural Mechanization',
    'SMAM',
    NULL,
    NULL,
    NULL,

    'Individual farmers, Self Help Groups (SHGs), Farmer Producer Organizations (FPOs), cooperatives, rural entrepreneurs, and Custom Hiring Centres as per state guidelines.',

    'Applicants who have already received subsidy for the same machinery within the prescribed period or do not meet state eligibility norms may be excluded.',

    'Aadhaar Card, Identity Proof, Land Records, Bank Account Details, Passport Size Photograph, Mobile Number, and any state-specific documents.',

    'Register on the state agriculture department portal, select machinery category, upload documents, submit application, and await verification and approval.',

    'Aadhaar-based verification or other methods specified by the implementing state department.',

    'Incorrect Aadhaar details, bank account mismatch, duplicate subsidy applications, invalid land records, or incomplete document uploads.',

    'Application Submitted, Under Verification, Approved, Subsidy Sanctioned, Rejected, or Payment Processed.',

    'Contact the respective State Agriculture Department or District Agriculture Office.',

    'https://agrimachinery.nic.in',

    'Farm Mechanization Subsidy',

    NULL,

    NULL,

    'Financial assistance for purchase of tractors, power tillers, harvesters, seed drills, planters, sprayers, and other agricultural machinery. Support is also available for establishing Custom Hiring Centres.',

    'Implemented across India to increase farm mechanization, improve productivity, reduce labour dependency, and promote access to modern agricultural equipment.',

    'Central',

    'Farm Mechanization'
);
ALTER TABLE government_schemes
ADD COLUMN scheme_category VARCHAR(100) NULL;
SELECT scheme_id, scheme_name, short_name
FROM government_schemes
WHERE short_name = 'SMAM';
INSERT INTO government_schemes (
    scheme_name,
    short_name,
    annual_benefit,
    installment_amount,
    installments_per_year,
    eligibility,
    exclusions,
    required_documents,
    registration_steps,
    ekyc_methods,
    common_errors,
    status_messages,
    helplines,
    official_website,
    scheme_type,
    interest_rate_info,
    loan_limit_info,
    benefits,
    coverage_details,
    scheme_level,
    target_sector
)
VALUES (
    'National Agriculture Market',
    'e-NAM',
    NULL,
    NULL,
    NULL,

    'Farmers, traders, FPOs, commission agents and buyers registered with participating mandis.',

    'Users not registered with participating mandis or failing verification requirements.',

    'Aadhaar Card, Mobile Number, Bank Account Details and Identity Proof.',

    'Register on the e-NAM portal or mobile app, complete verification, link bank account and begin trading.',

    'OTP-based mobile verification and Aadhaar-based authentication where applicable.',

    'Incorrect Aadhaar details, invalid bank information, incomplete registration and verification failures.',

    'Registration Submitted, Under Verification, Approved, Active, Transaction Completed and Payment Processed.',

    'e-NAM Helpdesk and State Agricultural Marketing Boards.',

    'https://enam.gov.in',

    'Agricultural Marketing Platform',

    NULL,

    NULL,

    'Provides transparent price discovery, online bidding, wider market access, electronic trading and digital payments for agricultural produce.',

    'Integrates APMC mandis across India into a unified electronic marketplace enabling inter-state and intra-state trade.',

    'Central',

    'Agricultural Marketing'
);
SELECT scheme_id, scheme_name
FROM government_schemes
WHERE short_name = 'e-NAM';
DESCRIBE scheme_faqs;
SHOW CREATE TABLE scheme_faqs;
INSERT INTO scheme_faqs
(
    scheme_name,
    question,
    answer,
    category,
    keywords,
    language
)
VALUES

('e-NAM',
'What is e-NAM?',
'National Agriculture Market (e-NAM) is a pan-India electronic trading platform that connects agricultural markets to facilitate transparent price discovery and better market access for farmers.',
'General Information',
'e-NAM,national agriculture market,online market,agricultural trading',
'english'),

('e-NAM',
'How do I register on e-NAM?',
'Farmers can register through the e-NAM portal, mobile app, or participating mandi by providing Aadhaar details, mobile number, bank account information, and other required documents.',
'Registration',
'registration,signup,enam portal,farmers',
'english'),

('e-NAM',
'Is e-NAM free for farmers?',
'Yes. Registration and participation on e-NAM are generally free for farmers.',
'Fees',
'free,charges,cost,registration fee',
'english'),

('e-NAM',
'Which states are covered under e-NAM?',
'e-NAM operates through hundreds of integrated APMC mandis across multiple states and union territories in India.',
'Coverage',
'states,coverage,mandis,india',
'english'),

('e-NAM',
'Can I sell produce outside my state?',
'Yes. e-NAM enables inter-state and intra-state trading, allowing buyers from different regions to participate in auctions.',
'Trading',
'interstate trading,sell produce,buyers,market access',
'english'),

('e-NAM',
'What crops can be traded on e-NAM?',
'A wide range of commodities including cereals, pulses, oilseeds, fruits, vegetables, spices, and other notified agricultural produce can be traded.',
'Commodities',
'crops,commodities,produce,trading',
'english'),

('e-NAM',
'How are prices determined?',
'Prices are determined through transparent online bidding and auction mechanisms where buyers compete for the produce.',
'Pricing',
'prices,bidding,auction,price discovery',
'english'),

('e-NAM',
'How do online bidding and auctions work?',
'Registered buyers submit bids electronically through the platform. The highest valid bid is selected according to mandi rules.',
'Trading',
'online bidding,auction,buyers,selling',
'english'),

('e-NAM',
'How do I receive payment?',
'Payments are usually transferred electronically to the farmer''s registered bank account after successful completion of the transaction.',
'Payments',
'payment,bank account,money transfer',
'english'),

('e-NAM',
'Can FPOs use e-NAM?',
'Yes. Farmer Producer Organizations (FPOs) can register and trade agricultural produce through the e-NAM platform.',
'Eligibility',
'FPO,farmer producer organization,registration',
'english'),

('e-NAM',
'What documents are required?',
'Commonly required documents include Aadhaar Card, mobile number, bank account details, identity proof, and mandi-specific documents.',
'Documentation',
'documents,aadhaar,bank account,identity proof',
'english'),

('e-NAM',
'Is Aadhaar mandatory?',
'Aadhaar is commonly used for identity verification. Requirements may vary depending on state regulations and mandi procedures.',
'Documentation',
'aadhaar,verification,identity proof',
'english'),

('e-NAM',
'How do I check mandi prices?',
'Farmers can view real-time mandi prices, arrivals, and bidding information through the e-NAM website and mobile application.',
'Market Information',
'mandi prices,market rates,price check',
'english'),

('e-NAM',
'Can traders register on e-NAM?',
'Yes. Licensed traders and eligible buyers can register on e-NAM subject to applicable state and mandi regulations.',
'Eligibility',
'traders,buyers,registration',
'english'),

('e-NAM',
'What should I do if my registration is rejected?',
'Review the rejection reason, correct any errors in submitted information or documents, and reapply. Assistance can also be sought from the mandi or e-NAM helpdesk.',
'Troubleshooting',
'registration rejected,error,helpdesk',
'english');
SHOW CREATE TABLE crop_advisories;
CREATE TABLE crops (
    crop_id INT AUTO_INCREMENT PRIMARY KEY,
    crop_name VARCHAR(100) NOT NULL,
    crop_category VARCHAR(100),
    primary_region VARCHAR(100),
    scientific_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE crop_production_guides (
    guide_id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT NOT NULL,

    season TEXT,
    soil_requirements TEXT,
    seed_rate TEXT,
    sowing_period TEXT,
    irrigation_requirements TEXT,
    fertilizer_recommendations TEXT,
    harvesting_guidelines TEXT,

    FOREIGN KEY (crop_id)
    REFERENCES crops(crop_id)
);
ALTER TABLE crop_advisories
ADD COLUMN advisory_type VARCHAR(100) AFTER crop_name,
ADD COLUMN advisory_title VARCHAR(255) AFTER advisory_type,
ADD COLUMN district VARCHAR(100) AFTER season,
ADD COLUMN keywords TEXT AFTER district,
ADD COLUMN language VARCHAR(20) DEFAULT 'english' AFTER keywords;
describe crop_advisories;
describe crops;
CREATE TABLE crop_guides (
    guide_id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT NOT NULL,
    season VARCHAR(100),
    soil_requirements TEXT,
    seed_rate TEXT,
    sowing_period TEXT,
    irrigation_requirements TEXT,
    fertilizer_recommendations TEXT,
    harvesting_guidelines TEXT,
    source VARCHAR(255),
    last_updated DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (crop_id)
        REFERENCES crops(crop_id)
        ON DELETE CASCADE
);
ALTER TABLE crop_advisories
ADD COLUMN severity ENUM('Low','Medium','High') NULL,
ADD COLUMN advisory_status ENUM('Active','Archived') DEFAULT 'Active';
RENAME TABLE crop_advisories TO crop_advisory_old;
CREATE TABLE crop_advisory (
    advisory_id INT AUTO_INCREMENT PRIMARY KEY,

    crop_id INT NOT NULL,

    advisory_category ENUM(
        'Weather',
        'Irrigation',
        'Pest',
        'Disease',
        'Nutrition',
        'Fertilizer',
        'Organic Practice',
        'Cultural Practice',
        'Harvest',
        'Post-Harvest',
        'General'
    ) NOT NULL,

    crop_stage VARCHAR(100),

    trigger_type ENUM(
        'Crop Stage',
        'Weather',
        'Pest',
        'Disease',
        'Nutrient Deficiency',
        'Farmer Query',
        'General'
    ) DEFAULT 'General',

    trigger_value VARCHAR(255),

    problem_name VARCHAR(255),

    recommendation TEXT NOT NULL,

    district VARCHAR(100),

    season VARCHAR(50),

    priority ENUM('Low', 'Medium', 'High', 'Critical') DEFAULT 'Medium',

    valid_from DATE,

    valid_until DATE,

    source VARCHAR(255),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (crop_id)
        REFERENCES crops(crop_id)
        ON DELETE CASCADE
);
CREATE TABLE advisory_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,

    category_name VARCHAR(100) NOT NULL UNIQUE,

    description TEXT
);
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
('General','General crop advice');
CREATE TABLE crop_stages (
    stage_id INT AUTO_INCREMENT PRIMARY KEY,

    stage_name VARCHAR(100) NOT NULL UNIQUE,

    description TEXT
);
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
('Any','Applicable to any stage');
CREATE TABLE trigger_types (
    trigger_type_id INT AUTO_INCREMENT PRIMARY KEY,

    trigger_name VARCHAR(100) NOT NULL UNIQUE,

    description TEXT
);
INSERT INTO trigger_types (trigger_name, description) VALUES
('Crop Stage','Triggered by crop growth stage'),
('Weather','Triggered by weather conditions'),
('Pest','Triggered by pest occurrence'),
('Disease','Triggered by disease symptoms'),
('Nutrient Deficiency','Triggered by nutrient deficiency'),
('Farmer Query','General farmer question'),
('Routine','Routine scheduled advisory'),
('General','General advisory');
CREATE TABLE seasons (
    season_id INT AUTO_INCREMENT PRIMARY KEY,
    season_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);
INSERT INTO seasons (season_name, description) VALUES
('Kharif','Monsoon cropping season'),
('Rabi','Winter cropping season'),
('Zaid','Summer cropping season'),
('Perennial','Applicable throughout the year'),
('All Seasons','Applicable in all seasons');
CREATE TABLE districts (

    district_id INT AUTO_INCREMENT PRIMARY KEY,

    state_name VARCHAR(100),

    district_name VARCHAR(100) NOT NULL,

    UNIQUE(state_name,district_name)
);
INSERT INTO districts(state_name,district_name)
VALUES
('Sikkim','East Sikkim'),
('Sikkim','West Sikkim'),
('Sikkim','North Sikkim'),
('Sikkim','South Sikkim');
ALTER TABLE crop_advisory
ADD district_id INT,
ADD season_id INT;
describe districts;
describe seasons;
ALTER TABLE crop_advisory
ADD CONSTRAINT fk_crop_advisory_district
FOREIGN KEY (district_id)
REFERENCES districts(district_id),

ADD CONSTRAINT fk_crop_advisory_season
FOREIGN KEY (season_id)
REFERENCES seasons(season_id);
ALTER TABLE crop_advisory
DROP COLUMN district,
DROP COLUMN season;
CREATE TABLE vector_embeddings (
    id INT AUTO_INCREMENT PRIMARY KEY,

    source_table VARCHAR(100) NOT NULL,

    source_id INT NOT NULL,

    content TEXT NOT NULL,

    vector JSON NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
DESCRIBE vector_embeddings;
SHOW CREATE TABLE vector_embeddings;
INSERT INTO vector_embeddings (source_table, source_id, content, vector)
VALUES

('government_schemes', 1,
'PM-KISAN: Central income support scheme for eligible landholding farmer families. Provides ₹6,000 annually in three DBT installments of ₹2,000 each. Requires Aadhaar, bank account, land records and mobile number. Registration through PM-KISAN portal, CSC or Agriculture Department. Excludes institutional landholders, income taxpayers and other notified ineligible categories.',
JSON_ARRAY()),

('government_schemes', 2,
'PMFBY (Pradhan Mantri Fasal Bima Yojana): Crop insurance against natural calamities, pests and diseases. Covers prevented sowing, yield loss, localized calamities, mid-season adversity and post-harvest losses for notified crops. Farmer premium: 2% for Kharif, 1.5% for Rabi and 5% for commercial and horticultural crops. Requires Aadhaar, land details, bank account and crop details.',
JSON_ARRAY()),

('government_schemes', 3,
'Kisan Credit Card (KCC): Provides affordable institutional credit for crop cultivation, allied agriculture and working capital. Features revolving credit, flexible repayment linked to harvest and concessional interest with interest subvention for timely repayment where applicable. Requires Aadhaar, land records, bank documents and PAN where applicable.',
JSON_ARRAY()),

('government_schemes', 4,
'Soil Health Card Scheme: Provides soil testing reports containing pH, organic carbon, nitrogen, phosphorus, potassium and micronutrients with nutrient management and fertilizer recommendations to improve soil fertility and crop productivity.',
JSON_ARRAY()),

('government_schemes', 5,
'Pradhan Mantri Krishi Sinchai Yojana (PMKSY): Improves irrigation coverage and water-use efficiency through Har Khet Ko Pani, Per Drop More Crop and Watershed Development. Supports micro-irrigation and water conservation.',
JSON_ARRAY()),

('government_schemes', 6,
'Paramparagat Krishi Vikas Yojana (PKVY): Promotes organic farming through cluster-based cultivation. Supports organic certification, farmer training, organic inputs and market linkage. Particularly beneficial for regions practicing organic agriculture.',
JSON_ARRAY()),

('government_schemes', 7,
'National Mission for Sustainable Agriculture (NMSA): Promotes climate-resilient agriculture through water conservation, improved soil health, resource-use efficiency and sustainable farming practices.',
JSON_ARRAY()),

('government_schemes', 8,
'Sub-Mission on Agricultural Mechanization (SMAM): Provides subsidies on agricultural machinery, promotes farm mechanization and supports Custom Hiring Centres, especially benefiting small and marginal farmers.',
JSON_ARRAY()),

('government_schemes', 9,
'e-NAM (National Agriculture Market): Online agricultural trading platform integrating regulated markets across India. Enables transparent price discovery, online trading, wider market access and reduced dependence on intermediaries.',
JSON_ARRAY()),

('government_schemes', 10,
'Agriculture Infrastructure Fund (AIF): Provides medium and long-term financing for warehouses, cold storage, collection centres, processing units and packing facilities. Offers interest subvention, credit guarantee support and infrastructure loans.',
JSON_ARRAY()),

('government_schemes', 11,
'National Livestock Mission (NLM): Supports livestock sectors including sheep, goat, poultry and piggery. Provides financial assistance, breed improvement, fodder development, entrepreneurship support and farmer training.',
JSON_ARRAY()),

('government_schemes', 12,
'Dairy-related schemes: Government initiatives supporting dairy farming through infrastructure development, milk production enhancement, dairy entrepreneurship, cooperative strengthening, financial assistance and modern dairy facilities.',
JSON_ARRAY()),

('government_schemes', 13,
'State-specific agriculture schemes: State government schemes supporting seed distribution, irrigation, horticulture, organic farming, livestock, farm mechanization and other region-specific agricultural assistance programmes.',
JSON_ARRAY());
CREATE INDEX idx_crop_advisory_crop
ON crop_advisory(crop_id);

CREATE INDEX idx_crop_advisory_stage
ON crop_advisory(stage_id);

CREATE INDEX idx_crop_advisory_category
ON crop_advisory(category_id);

CREATE INDEX idx_crop_advisory_trigger
ON crop_advisory(trigger_type_id);

CREATE INDEX idx_crop_advisory_district
ON crop_advisory(district_id);

CREATE INDEX idx_crop_advisory_season
ON crop_advisory(season_id);
CREATE TABLE crop_advisory (

    advisory_id INT AUTO_INCREMENT PRIMARY KEY,

    crop_id INT NOT NULL,

    category_id INT NOT NULL,

    stage_id INT,

    trigger_type_id INT NOT NULL,

    trigger_condition VARCHAR(255) NOT NULL,

    recommendation TEXT NOT NULL,

    district_id INT,

    season_id INT,

    priority ENUM('Low','Medium','High','Critical')
        DEFAULT 'Medium',

    advisory_type ENUM(
        'Preventive',
        'Corrective',
        'Emergency',
        'Informational'
    ) DEFAULT 'Informational',

    source VARCHAR(255),

    valid_from DATE,

    valid_until DATE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (crop_id)
        REFERENCES crops(crop_id),

    FOREIGN KEY (category_id)
        REFERENCES advisory_categories(category_id),

    FOREIGN KEY (stage_id)
        REFERENCES crop_stages(stage_id),

    FOREIGN KEY (trigger_type_id)
        REFERENCES trigger_types(trigger_type_id),

    FOREIGN KEY (district_id)
        REFERENCES districts(district_id),

    FOREIGN KEY (season_id)
        REFERENCES seasons(season_id)
);
CREATE INDEX idx_advisory_crop ON crop_advisory(crop_id);
CREATE INDEX idx_advisory_category ON crop_advisory(category_id);
CREATE INDEX idx_advisory_stage ON crop_advisory(stage_id);
CREATE INDEX idx_advisory_trigger_type ON crop_advisory(trigger_type_id);
CREATE INDEX idx_advisory_district ON crop_advisory(district_id);
CREATE INDEX idx_advisory_season ON crop_advisory(season_id);
CREATE INDEX idx_advisory_priority ON crop_advisory(priority);
ALTER TABLE crops
ADD COLUMN crop_type ENUM(
    'Annual',
    'Biennial',
    'Perennial'
) NOT NULL DEFAULT 'Annual' AFTER crop_category,

ADD COLUMN growing_duration_days SMALLINT NULL AFTER crop_type,

ADD COLUMN water_requirement ENUM(
    'Low',
    'Medium',
    'High'
) NULL AFTER growing_duration_days,

ADD COLUMN description TEXT NULL AFTER water_requirement;
SELECT * FROM crops;
INSERT INTO crops
(crop_name, crop_category, primary_region, scientific_name)
VALUES

('Tea', 'Plantation', 'Darjeeling', 'Camellia sinensis'),

('Large Cardamom', 'Spice', 'Darjeeling Hills', 'Amomum subulatum'),

('Ginger', 'Spice', 'Darjeeling Hills', 'Zingiber officinale'),

('Turmeric', 'Spice', 'Darjeeling Hills', 'Curcuma longa'),

('French Bean', 'Vegetable', 'Darjeeling Hills', 'Phaseolus vulgaris'),

('Potato', 'Vegetable', 'Darjeeling Hills', 'Solanum tuberosum'),

('Maize', 'Cereal', 'Darjeeling Hills', 'Zea mays'),

('Rice', 'Cereal', 'Darjeeling Plains', 'Oryza sativa'),

('Orange', 'Fruit', 'Darjeeling Hills', 'Citrus reticulata'),

('Cabbage', 'Vegetable', 'Darjeeling Hills', 'Brassica oleracea var. capitata'),

('Cauliflower', 'Vegetable', 'Darjeeling Hills', 'Brassica oleracea var. botrytis'),

('Tomato', 'Vegetable', 'Darjeeling Hills', 'Solanum lycopersicum');
INSERT INTO advisory_categories
(category_name, description)
VALUES

('Sowing Advisory',
'Information about planting time, seed selection and sowing methods'),

('Irrigation Management',
'Water requirements and irrigation practices'),

('Nutrient Management',
'Guidance on soil nutrients and organic inputs'),

('Pest Management',
'Identification and control of insect pests'),

('Disease Management',
'Prevention and treatment of crop diseases'),

('Weed Management',
'Methods to control unwanted plants'),

('Harvest Advisory',
'Guidance on harvesting time and methods'),

('Storage Advisory',
'Post-harvest storage practices'),

('Weather Advisory',
'Crop advice based on weather conditions');
INSERT INTO trigger_types
(trigger_name, description)
VALUES

('Disease Symptoms',
'Triggered when farmer reports disease signs'),

('Pest Attack',
'Triggered when insects or pests are reported'),

('Weather Event',
'Triggered due to rain, drought, frost or extreme weather'),

('Growth Problem',
'Triggered when crop growth is abnormal'),

('Nutrient Deficiency',
'Triggered when plants show nutrient deficiency symptoms'),

('Low Yield',
'Triggered when farmer reports poor production'),

('General Query',
'Triggered for normal farming questions');
UPDATE crops
SET crop_duration='Perennial'
WHERE crop_id IN (
    SELECT crop_id 
    FROM (
        SELECT crop_id 
        FROM crops
        WHERE crop_name IN ('Tea','Large Cardamom','Orange')
    ) AS temp
);
UPDATE crops
SET crop_duration='Annual'
WHERE crop_id NOT IN (
    SELECT crop_id 
    FROM (
        SELECT crop_id 
        FROM crops
        WHERE crop_name IN ('Tea','Large Cardamom','Orange')
    ) AS temp
);
INSERT INTO crops 
(crop_name, crop_category, primary_region, scientific_name, crop_duration)
VALUES
('French Bean','Vegetable','Darjeeling Hills','Phaseolus vulgaris','Annual'),
('Maize','Cereal','Darjeeling Hills','Zea mays','Annual'),
('Potato','Tuber Crop','Darjeeling Hills','Solanum tuberosum','Annual'),
('Orange','Fruit','Darjeeling Hills','Citrus reticulata','Perennial'),
('Turmeric','Spice','Darjeeling Hills','Curcuma longa','Annual');
SET SQL_SAFE_UPDATES = 0;
UPDATE crops
SET 
growing_duration_days = 365,
water_requirement = 'Moderate rainfall; requires well-drained soil and regular moisture',
description = 'Evergreen plantation crop grown in Darjeeling hills. Leaves are harvested multiple times annually for tea production.'
WHERE crop_name = 'Tea';


UPDATE crops
SET 
growing_duration_days = 730,
water_requirement = 'High humidity and regular rainfall; prefers moist but well-drained soil',
description = 'Perennial spice crop grown in the Darjeeling hills. The dried capsules are used as a valuable spice.'
WHERE crop_name = 'Large Cardamom';


UPDATE crops
SET 
growing_duration_days = 180,
water_requirement = 'Moderate water requirement; requires regular irrigation during dry periods',
description = 'Annual spice crop cultivated for underground rhizomes used as fresh and dried ginger.'
WHERE crop_name = 'Ginger';


UPDATE crops
SET 
growing_duration_days = 365,
water_requirement = 'Moderate water requirement; requires rainfall with good drainage',
description = 'Perennial fruit crop grown in Darjeeling hills. Produces mandarin oranges suited to hill climates.'
WHERE crop_name = 'Orange';


UPDATE crops
SET 
growing_duration_days = 90,
water_requirement = 'Moderate irrigation required, especially during flowering and pod formation',
description = 'Annual vegetable crop grown widely in hill regions. Suitable for cool climates and multiple seasonal cultivation.'
WHERE crop_name = 'French Bean';


UPDATE crops
SET 
growing_duration_days = 120,
water_requirement = 'Moderate water requirement; requires adequate moisture during growth',
description = 'Annual cereal crop cultivated in hill regions for grain and food security.'
WHERE crop_name = 'Maize';


UPDATE crops
SET 
growing_duration_days = 120,
water_requirement = 'Moderate irrigation; sensitive to excessive waterlogging',
description = 'Annual tuber crop grown in cooler climates. Important vegetable and cash crop in hill farming.'
WHERE crop_name = 'Potato';


UPDATE crops
SET 
growing_duration_days = 270,
water_requirement = 'Moderate rainfall with good drainage',
description = 'Annual spice crop cultivated for its underground rhizomes used as a culinary spice and medicinal ingredient.'
WHERE crop_name = 'Turmeric';
ALTER TABLE crops
MODIFY COLUMN water_requirement TEXT;
UPDATE crops
SET 
growing_duration_days = 365,
water_requirement = 'Moderate rainfall; requires well-drained soil and regular moisture',
description = 'Evergreen plantation crop grown in Darjeeling hills. Leaves are harvested multiple times annually for tea production.'
WHERE crop_name = 'Tea';


UPDATE crops
SET 
growing_duration_days = 730,
water_requirement = 'High humidity and regular rainfall; prefers moist but well-drained soil',
description = 'Perennial spice crop grown in the Darjeeling hills. The dried capsules are used as a valuable spice.'
WHERE crop_name = 'Large Cardamom';


UPDATE crops
SET 
growing_duration_days = 180,
water_requirement = 'Moderate water requirement; requires regular irrigation during dry periods',
description = 'Annual spice crop cultivated for underground rhizomes used as fresh and dried ginger.'
WHERE crop_name = 'Ginger';


UPDATE crops
SET 
growing_duration_days = 365,
water_requirement = 'Moderate water requirement; requires rainfall with good drainage',
description = 'Perennial fruit crop grown in Darjeeling hills. Produces mandarin oranges suited to hill climates.'
WHERE crop_name = 'Orange';


UPDATE crops
SET 
growing_duration_days = 90,
water_requirement = 'Moderate irrigation required, especially during flowering and pod formation',
description = 'Annual vegetable crop grown widely in hill regions. Suitable for cool climates and multiple seasonal cultivation.'
WHERE crop_name = 'French Bean';


UPDATE crops
SET 
growing_duration_days = 120,
water_requirement = 'Moderate water requirement; requires adequate moisture during growth',
description = 'Annual cereal crop cultivated in hill regions for grain and food security.'
WHERE crop_name = 'Maize';


UPDATE crops
SET 
growing_duration_days = 120,
water_requirement = 'Moderate irrigation; sensitive to excessive waterlogging',
description = 'Annual tuber crop grown in cooler climates. Important vegetable and cash crop in hill farming.'
WHERE crop_name = 'Potato';


UPDATE crops
SET 
growing_duration_days = 270,
water_requirement = 'Moderate rainfall with good drainage',
description = 'Annual spice crop cultivated for its underground rhizomes used as a culinary spice and medicinal ingredient.'
WHERE crop_name = 'Turmeric';
INSERT INTO crop_production_guides
(crop_id, season, soil_requirements, seed_rate, sowing_period, irrigation_requirements, fertilizer_recommendations, harvesting_guidelines)
VALUES
(
1,
'Year-round',
'Deep, well-drained acidic loamy soil (pH 4.5–5.5)',
'Vegetatively propagated through rooted cuttings or nursery plants',
'Best planting during June–September',
'Requires regular rainfall (1500–3000 mm annually); supplementary irrigation during dry spells',
'Apply organic manure along with balanced NPK based on soil test recommendations',
'Young bushes begin yielding after 3–4 years; pluck two leaves and a bud every 7–15 days during the harvesting season.'
);
INSERT INTO crop_production_guides
(crop_id, season, soil_requirements, seed_rate, sowing_period, irrigation_requirements, fertilizer_recommendations, harvesting_guidelines)
VALUES
(
2,
'Monsoon',
'Moist, well-drained loamy soil rich in organic matter under partial shade',
'Suckers or tissue-cultured planting material',
'June–July',
'Requires frequent moisture and mulching; avoid waterlogging',
'Apply compost/FYM with recommended NPK based on soil analysis',
'Harvest mature capsules between September and November and cure before storage.'
);
INSERT INTO crop_production_guides
(crop_id, season, soil_requirements, seed_rate, sowing_period, irrigation_requirements, fertilizer_recommendations, harvesting_guidelines)
VALUES
(
3,
'Kharif',
'Loose, fertile, well-drained loamy soil rich in organic matter',
'1500–2000 kg seed rhizomes per hectare',
'April–May',
'Maintain adequate moisture without waterlogging',
'Incorporate well-decomposed FYM and apply NPK according to soil test recommendations',
'Harvest after 7–8 months when leaves turn yellow and dry.'
);
INSERT INTO crop_production_guides
(crop_id, season, soil_requirements, seed_rate, sowing_period, irrigation_requirements, fertilizer_recommendations, harvesting_guidelines)
VALUES
(
4,
'Perennial',
'Well-drained sandy loam to loam soil with pH 5.5–7.0',
'Healthy grafted saplings',
'July–August',
'Irrigate during prolonged dry periods and avoid water stagnation',
'Apply organic manure annually with balanced NPK based on tree age',
'Harvest fully developed fruits during November–January.'
);
INSERT INTO crop_production_guides
(
    crop_id,
    season,
    soil_requirements,
    seed_rate,
    sowing_period,
    irrigation_requirements,
    fertilizer_recommendations,
    harvesting_guidelines
)
VALUES
(
    5,
    'Kharif, Spring and Autumn (depending on region)',
    'Well-drained fertile loamy soil rich in organic matter with pH 5.5–6.8. Avoid waterlogged fields.',
    'Bush varieties: 60–80 kg/ha; Pole varieties: 25–30 kg/ha.',
    'Spring: February–March; Kharif: June–July; Autumn: September–October (varies by region and altitude).',
    'Provide light irrigation immediately after sowing. Irrigate every 7–10 days depending on rainfall and soil moisture. Critical stages are flowering and pod development. Avoid waterlogging.',
    'Incorporate 15–20 tonnes/ha of well-decomposed FYM before sowing. Apply balanced NPK based on soil test recommendations. Split nitrogen application between sowing and flowering. Use organic manure and biofertilizers wherever possible.',
    'Harvest tender green pods 50–60 days after sowing for bush varieties and 60–75 days for pole varieties. Pick pods every 2–3 days to encourage continuous production. Harvest during the cool hours of the day and handle carefully to avoid bruising.'
);
INSERT INTO crop_production_guides
(crop_id, season, soil_requirements, seed_rate, sowing_period, irrigation_requirements, fertilizer_recommendations, harvesting_guidelines)
VALUES

-- Tea
(1,
'Throughout the year; best planting during monsoon',
'Deep, well-drained acidic loamy soil with pH 4.5–5.5 rich in organic matter.',
'Vegetative propagated saplings; approximately 12,000–14,000 plants/ha.',
'June–September is ideal for planting.',
'Regular irrigation during dry months; avoid waterlogging.',
'Apply organic manure annually and balanced NPK based on soil test recommendations.',
'Pluck two leaves and a bud every 7–10 days after bushes attain maturity.'),

-- Large Cardamom
(2,
'Monsoon',
'Well-drained forest loam rich in organic matter with pH 5.0–6.5.',
'Suckers or healthy planting material; about 2,500–3,000 clumps/ha.',
'May–July.',
'Maintain consistent moisture through mulching and supplemental irrigation during dry spells.',
'Apply well-decomposed FYM along with recommended NPK in split doses.',
'Harvest mature capsules from September to November before over-ripening.'),

-- Ginger
(3,
'Kharif',
'Loose fertile loamy soil rich in organic matter with good drainage.',
'1500–2000 kg healthy rhizomes/ha.',
'April–June.',
'Irrigate immediately after planting and subsequently every 7–10 days depending on rainfall.',
'Apply 20–25 t/ha FYM with recommended NPK in split applications.',
'Harvest 7–9 months after planting when leaves begin yellowing.'),

-- Turmeric
(4,
'Kharif',
'Well-drained sandy loam or loamy soil rich in organic matter.',
'2000–2500 kg seed rhizomes/ha.',
'April–June.',
'Maintain adequate soil moisture throughout crop growth.',
'Apply organic manure before planting and balanced NPK in split doses.',
'Harvest 8–9 months after planting when foliage dries.'),

-- Potato
(6,
'Rabi',
'Well-drained sandy loam with pH 5.5–6.5.',
'2500–3000 kg certified seed tubers/ha.',
'October–November in plains; February–March in hills.',
'Irrigate immediately after planting and thereafter every 7–10 days. Avoid excess moisture.',
'Apply FYM before planting and recommended NPK based on soil test.',
'Harvest after vines dry and skins harden, generally 90–120 days after planting.'),

-- Maize
(7,
'Kharif, Rabi and Spring',
'Well-drained fertile loamy soil with pH 5.5–7.5.',
'18–25 kg seed/ha.',
'June–July (Kharif), October–November (Rabi), January–February (Spring).',
'Critical irrigation at knee-high, tasseling and grain filling stages.',
'Apply FYM before sowing and recommended NPK in split applications.',
'Harvest when cobs are fully mature and grains reach physiological maturity.'),

-- Rice
(8,
'Kharif',
'Clay loam to loamy soil with good water-holding capacity.',
'20–40 kg seed/ha for transplanted rice.',
'Nursery: May–June; Transplanting: June–July.',
'Maintain standing water during vegetative stage and proper drainage before harvest.',
'Apply recommended NPK according to soil test and split nitrogen application.',
'Harvest when about 80–85% grains turn golden yellow.'),

-- Orange
(9,
'Monsoon and Spring',
'Well-drained sandy loam with pH 5.5–7.0.',
'Healthy grafted saplings; spacing approximately 6 m × 6 m.',
'July–August or February–March.',
'Young plants require regular irrigation; mature trees during dry periods.',
'Apply FYM annually with balanced NPK based on tree age.',
'Harvest fully mature fruits showing proper colour and sweetness.'),

-- Cabbage
(10,
'Rabi and Winter',
'Fertile well-drained loamy soil with pH 6.0–6.8.',
'400–500 g seed/ha for nursery.',
'Nursery: August–October; Transplanting: September–November.',
'Irrigate every 7–10 days while avoiding waterlogging.',
'Apply FYM before transplanting and recommended NPK in split doses.',
'Harvest when heads become firm and compact.'),

-- Cauliflower
(11,
'Rabi and Winter',
'Well-drained fertile loam with pH 6.0–7.0.',
'500–700 g seed/ha.',
'Nursery: May–September depending on variety; transplant after 30–40 days.',
'Maintain uniform soil moisture throughout growth.',
'Apply FYM before planting with balanced NPK according to soil test.',
'Harvest when curds are compact, white and fully developed.'),

-- Tomato
(12,
'Kharif, Rabi and Summer',
'Well-drained fertile loamy soil with pH 6.0–7.0.',
'250–350 g seed/ha for nursery.',
'June–July, October–November or January–February depending on season.',
'Irrigate every 5–7 days; avoid moisture stress during flowering and fruiting.',
'Apply 20–25 t/ha FYM and recommended NPK in split doses. Support integrated nutrient management.',
'Harvest fully developed fruits at the mature green, breaker or ripe stage depending on market requirement.');
SELECT
    crop_name,
    COUNT(*) AS duplicate_count
FROM crops
GROUP BY crop_name
HAVING COUNT(*) > 1;
SELECT *
FROM crops
WHERE crop_id NOT IN (
    SELECT keep_id
    FROM (
        SELECT MIN(crop_id) AS keep_id
        FROM crops
        GROUP BY crop_name
    ) AS x
)
ORDER BY crop_name, crop_id;
DELETE FROM crops
WHERE crop_id NOT IN (
    SELECT keep_id
    FROM (
        SELECT MIN(crop_id) AS keep_id
        FROM crops
        GROUP BY crop_name
    ) AS x
);
INSERT INTO crop_production_guides
(crop_id, season, soil_requirements, seed_rate, sowing_period, irrigation_requirements, fertilizer_recommendations, harvesting_guidelines)
VALUES

-- 1. Tea
(1,
'Perennial crop; planting mainly during monsoon (June–September)',
'Deep, well-drained acidic loamy soil rich in organic matter with pH 4.5–5.5.',
'Vegetatively propagated saplings; approximately 12,000–14,000 plants/ha.',
'June–September is ideal for new plantations.',
'Young plants require regular irrigation during dry periods. Mature plants generally depend on rainfall but may need supplemental irrigation during prolonged dry spells.',
'Apply well-decomposed organic manure annually along with balanced NPK based on soil test recommendations. Pruning residues can be composted and reused.',
'Plucking begins after bushes mature. Harvest two leaves and one bud every 7–10 days during the active growing season.'),

-- 2. Large Cardamom
(2,
'Perennial; monsoon planting',
'Well-drained forest loam rich in organic matter with pH 5.0–6.5 under partial shade.',
'Healthy suckers or tissue-cultured plants; about 2,500–3,000 clumps/ha.',
'May–July.',
'Maintain adequate soil moisture through mulching and irrigation during dry months while avoiding waterlogging.',
'Apply 10–15 kg FYM per clump annually with balanced NPK as per soil test recommendations.',
'Harvest mature capsules from September to November. Dry immediately after harvest to preserve quality.'),

-- 3. Ginger
(3,
'Kharif',
'Loose, fertile, well-drained loamy soil rich in organic matter with pH 5.5–6.5.',
'1,500–2,000 kg healthy seed rhizomes/ha.',
'April–June.',
'Irrigate immediately after planting and subsequently every 7–10 days depending on rainfall.',
'Apply 20–25 t/ha FYM before planting along with recommended NPK in split doses.',
'Harvest after 7–9 months when leaves turn yellow and begin drying.'),

-- 4. Turmeric
(4,
'Kharif',
'Well-drained sandy loam or loamy soil rich in organic matter with pH 5.5–7.0.',
'2,000–2,500 kg seed rhizomes/ha.',
'April–June.',
'Maintain consistent soil moisture throughout crop growth without waterlogging.',
'Apply 20–25 t/ha FYM before planting and recommended NPK in split applications.',
'Harvest after 8–9 months when foliage completely dries.'),

-- 5. French Bean
(5,
'Spring, Kharif and Autumn depending on region',
'Well-drained fertile loamy soil with pH 5.5–6.8.',
'Bush: 60–80 kg/ha; Pole: 25–30 kg/ha.',
'February–March, June–July and September–October depending on season.',
'Provide light irrigation after sowing and every 7–10 days during flowering and pod development.',
'Apply 15–20 t/ha FYM before sowing with balanced NPK according to soil test.',
'Harvest tender pods 50–75 days after sowing. Pick every 2–3 days for continuous production.'),

-- 6. Potato
(6,
'Rabi',
'Well-drained sandy loam with pH 5.5–6.5.',
'2,500–3,000 kg certified seed tubers/ha.',
'October–November in plains; February–March in hills.',
'Irrigate after planting and every 7–10 days. Avoid waterlogging.',
'Apply FYM before planting with recommended NPK in split doses.',
'Harvest 90–120 days after planting when vines dry and tubers mature.'),

-- 7. Maize
(7,
'Kharif, Rabi and Spring',
'Fertile, well-drained loamy soil with pH 5.5–7.5.',
'18–25 kg seed/ha.',
'June–July, October–November or January–February depending on season.',
'Critical irrigation at knee-high, tasseling and grain-filling stages.',
'Apply FYM before sowing and recommended NPK in split applications.',
'Harvest when cobs mature and grains become hard with proper moisture content.'),

-- 8. Rice
(8,
'Kharif',
'Clay loam to loamy soil with good water-holding capacity.',
'20–40 kg seed/ha for transplanted rice.',
'Nursery in May–June; transplanting in June–July.',
'Maintain shallow standing water during vegetative growth and drain before harvest.',
'Apply recommended NPK based on soil test with split nitrogen application.',
'Harvest when 80–85% of grains turn golden yellow.'),

-- 9. Orange
(9,
'Perennial; planting during monsoon or spring',
'Well-drained sandy loam with pH 5.5–7.0.',
'Healthy grafted saplings planted at approximately 6 × 6 m spacing.',
'July–August or February–March.',
'Young trees require regular irrigation. Mature trees need irrigation during prolonged dry periods.',
'Apply FYM annually along with balanced NPK according to tree age and soil test.',
'Harvest mature fruits when they develop full colour and optimum sweetness.'),

-- 10. Cabbage
(10,
'Rabi/Winter',
'Fertile well-drained loamy soil with pH 6.0–6.8.',
'400–500 g seed/ha for nursery.',
'Nursery: August–October; transplant after 30–40 days.',
'Irrigate every 7–10 days while preventing waterlogging.',
'Apply FYM before transplanting and balanced NPK in split doses.',
'Harvest when heads are compact, firm and fully developed.'),

-- 11. Cauliflower
(11,
'Rabi/Winter',
'Well-drained fertile loam with pH 6.0–7.0.',
'500–700 g seed/ha.',
'Nursery: May–September depending on variety.',
'Maintain uniform soil moisture throughout growth.',
'Apply FYM before planting with balanced NPK according to soil test.',
'Harvest when curds are compact, white and before flower buds loosen.'),

-- 12. Tomato
(12,
'Kharif, Rabi and Summer',
'Well-drained fertile loamy soil rich in organic matter with pH 6.0–7.0.',
'250–350 g seed/ha for nursery.',
'June–July, October–November or January–February depending on region.',
'Irrigate every 5–7 days, especially during flowering and fruit development.',
'Apply 20–25 t/ha FYM before planting with recommended NPK in split doses. Stake plants where necessary.',
'Harvest fruits at mature green, breaker or fully ripe stage depending on market demand.');
UPDATE crops
SET
    growing_duration_days = 1825,
    water_requirement = 'High',
    description = 'Tea is a perennial plantation crop grown for its tender leaves. It thrives in cool, humid climates with well-distributed rainfall and is one of the most important commercial crops in the Himalayan region.'
WHERE crop_id = 1;

UPDATE crops
SET
    growing_duration_days = 1095,
    water_requirement = 'Medium',
    description = 'Large Cardamom is a perennial spice crop cultivated under partial shade in hilly regions. It is valued for its aromatic capsules and is an important cash crop of Northeast India and Darjeeling hills.'
WHERE crop_id = 2;

UPDATE crops
SET
    growing_duration_days = 240,
    water_requirement = 'Medium',
    description = 'Ginger is a rhizome spice crop grown for its pungent underground stems. It prefers warm, humid climates and well-drained fertile soils.'
WHERE crop_id = 3;

UPDATE crops
SET
    growing_duration_days = 270,
    water_requirement = 'Medium',
    description = 'Turmeric is a tropical spice crop cultivated for its underground rhizomes. It is widely used as a spice, natural coloring agent, and medicinal plant.'
WHERE crop_id = 4;

UPDATE crops
SET
    growing_duration_days = 75,
    water_requirement = 'Medium',
    description = 'French Bean is a nutritious legume vegetable grown for its tender green pods. It performs well in cool to moderate climates and improves soil fertility through nitrogen fixation.'
WHERE crop_id = 5;

UPDATE crops
SET
    growing_duration_days = 110,
    water_requirement = 'Medium',
    description = 'Potato is a tuber crop grown for its edible underground tubers. It prefers cool weather and fertile, well-drained soils.'
WHERE crop_id = 6;

UPDATE crops
SET
    growing_duration_days = 110,
    water_requirement = 'Medium',
    description = 'Maize is a cereal crop cultivated for grain, fodder, and industrial uses. It adapts well to diverse climatic conditions and has high yield potential.'
WHERE crop_id = 7;

UPDATE crops
SET
    growing_duration_days = 135,
    water_requirement = 'High',
    description = 'Rice is the principal staple cereal crop requiring abundant water during most of its growth period. It is widely cultivated in irrigated and rainfed ecosystems.'
WHERE crop_id = 8;

UPDATE crops
SET
    growing_duration_days = 1095,
    water_requirement = 'Medium',
    description = 'Orange is a perennial citrus fruit crop valued for its nutritious and flavorful fruits. It grows best in subtropical climates with well-drained soils.'
WHERE crop_id = 9;

UPDATE crops
SET
    growing_duration_days = 120,
    water_requirement = 'Medium',
    description = 'Cabbage is a leafy vegetable grown for its compact heads. It performs best in cool climates and fertile soils with consistent moisture.'
WHERE crop_id = 10;

UPDATE crops
SET
    growing_duration_days = 110,
    water_requirement = 'Medium',
    description = 'Cauliflower is a cool-season vegetable cultivated for its edible white curd. It requires fertile soil and uniform moisture for high-quality production.'
WHERE crop_id = 11;

UPDATE crops
SET
    growing_duration_days = 120,
    water_requirement = 'Medium',
    description = 'Tomato is a widely cultivated vegetable crop grown for its edible fruits. It is an important source of vitamins and is used fresh as well as in processed products.'
WHERE crop_id = 12;
INSERT INTO crop_advisory
(crop_id, category_id, stage_id, trigger_type_id, trigger_condition, recommendation, district_id, season_id, priority, advisory_type, source, valid_from, valid_until)
VALUES

(1,12,1,7,
'Before land preparation',
'Select high-quality, disease-free tea planting material from certified nurseries. Prepare the field with proper drainage before planting.',
1,4,'Medium','Preventive','Tea Board of India','2026-01-01',NULL),

(1,8,4,1,
'At planting stage',
'Maintain recommended spacing and plant during periods of adequate soil moisture to ensure good establishment.',
1,4,'Medium','Preventive','Tea Board of India','2026-01-01',NULL),

(1,20,7,2,
'Heavy rainfall forecast',
'Clean drainage channels immediately to prevent waterlogging and reduce root diseases.',
1,4,'High','Emergency','IMD / Tea Board of India','2026-01-01',NULL),

(1,13,7,7,
'Extended dry spell',
'Provide light irrigation to young tea bushes and apply mulch to conserve soil moisture.',
1,4,'Medium','Preventive','Tea Board of India','2026-01-01',NULL),

(1,15,7,3,
'Tea mosquito bug observed',
'Monitor affected bushes regularly and adopt integrated pest management practices. Remove severely affected shoots.',
1,4,'High','Corrective','ICAR','2026-01-01',NULL),

(1,16,7,4,
'Blister blight symptoms detected',
'Remove infected leaves and maintain field sanitation. Follow recommended fungicidal or organic control measures where appropriate.',
1,4,'High','Corrective','ICAR','2026-01-01',NULL),

(1,14,7,7,
'Routine nutrient management',
'Apply well-decomposed compost or recommended nutrients based on soil test results to maintain healthy bush growth.',
1,4,'Medium','Preventive','ICAR','2026-01-01',NULL),

(1,18,14,1,
'Harvest stage reached',
'Pluck only two leaves and one bud at regular intervals to maintain premium tea quality.',
1,4,'Medium','Informational','Tea Board of India','2026-01-01',NULL),

(1,19,15,7,
'Immediately after harvest',
'Store harvested green leaves in a cool, shaded, well-ventilated place and transport promptly for processing.',
1,4,'Low','Informational','Tea Board of India','2026-01-01',NULL),

(1,11,16,8,
'General crop maintenance',
'Regularly prune bushes, remove weeds, monitor pests and diseases, and maintain field hygiene throughout the year.',
1,4,'Low','Informational','Tea Board of India','2026-01-01',NULL);
INSERT INTO districts (state_name, district_name)
VALUES ('West Bengal', 'Darjeeling');
UPDATE crop_advisory
SET district_id = 5
WHERE crop_id = 1
  AND district_id = 1;
 UPDATE crop_advisory
SET district_id = 5
WHERE crop_id = 1
  AND district_id = 1;
 INSERT INTO crop_advisory
(
    crop_id,
    category_id,
    stage_id,
    trigger_type_id,
    trigger_condition,
    recommendation,
    district_id,
    season_id,
    priority,
    advisory_type,
    source,
    valid_from,
    valid_until
)
VALUES

-- 1. Site selection, shade and drainage
(
    2,
    8,
    1,
    1,
    'Before establishing a large cardamom plantation',
    'Select well-drained forest-loamy soil on gentle to medium slopes. Avoid waterlogged sites and maintain suitable partial shade; around 50% shade is recommended in the Sikkim cultivation guidance. Use contour-based layout where appropriate to reduce erosion on slopes.',
    5,
    4,
    'High',
    'Preventive',
    'Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 2. Healthy planting material
(
    2,
    16,
    2,
    4,
    'Selecting planting material for a new plantation or gap filling',
    'Use healthy, disease-free planting material. Avoid collecting planting material from gardens showing Chirkey, Furkey or other disease symptoms. Inspect mother clumps carefully before selecting planting material.',
    5,
    4,
    'Critical',
    'Preventive',
    'Agriculture Department, Government of Sikkim; ICAR Kharif Agro-Advisories 2025',
    NULL,
    NULL
),

-- 3. Planting period
(
    2,
    12,
    4,
    1,
    'Planting during the suitable establishment period',
    'Plant large cardamom mainly during May to July, with June to July being the preferred period in the Sikkim cultivation guidance when soil moisture is suitable. Use mature tillers with appropriate vegetative buds as planting material.',
    5,
    4,
    'High',
    'Preventive',
    'Agriculture Department, Government of Sikkim; ICAR Kharif Agro-Advisories 2025',
    NULL,
    NULL
),

-- 4. Moisture and drainage management
(
    2,
    13,
    7,
    2,
    'Dry periods or inadequate soil moisture',
    'Maintain adequate soil moisture during dry periods while preventing waterlogging. Ensure drainage channels remain functional, particularly on sloping land, because excess water is unsuitable for large cardamom.',
    5,
    4,
    'High',
    'Preventive',
    'Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 5. Weed management
(
    2,
    17,
    7,
    7,
    'Weed growth in the plantation',
    'Carry out regular weeding to reduce competition and maintain field sanitation. ICAR recommends regular weeding in June and again in August for large cardamom fields. Avoid leaving excessive old plant debris and weeds in the plantation.',
    5,
    4,
    'Medium',
    'Preventive',
    'ICAR Kharif Agro-Advisories 2025',
    NULL,
    NULL
),

-- 6. Chirkey
(
    2,
    16,
    7,
    4,
    'Pale green or yellow longitudinal mosaic streaks appearing on young leaves',
    'Inspect plants regularly for Chirkey symptoms. Do not use infected planting material. Remove and destroy severely affected plants to reduce disease spread, maintain field sanitation, and sterilize tools before working in healthy areas.',
    5,
    4,
    'Critical',
    'Corrective',
    'Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 7. Furkey
(
    2,
    16,
    7,
    4,
    'Stunted shoots, small pale-green curled leaves and poor flowering',
    'Inspect the plantation for Furkey symptoms. Remove and destroy infected plants, avoid collecting planting material from affected gardens, maintain field sanitation, and sterilize tools to reduce mechanical transmission. Do not use infected plants for propagation.',
    5,
    4,
    'Critical',
    'Corrective',
    'Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 8. Anthracnose / leaf blight
(
    2,
    16,
    7,
    4,
    'Water-soaked leaf lesions that enlarge and develop into brown or black blighted areas',
    'Inspect leaves and pseudostems regularly. Avoid collecting planting material from infected gardens, remove diseased plant material and field debris, maintain field sanitation, and use healthy planting material. The Sikkim Agriculture Department recommends biological management measures including Trichoderma harzianum and Pseudomonas fluorescens.',
    5,
    4,
    'High',
    'Corrective',
    'Agriculture Department, Government of Sikkim; ICAR Kharif Agro-Advisories 2025',
    NULL,
    NULL
),

-- 9. Insect pest management
(
    2,
    15,
    7,
    3,
    'Insect pest activity is observed in the plantation',
    'Inspect plants regularly for insect pests and manage them using integrated pest management practices. ICAR recommends neem oil at 1500 ppm at 3 ml per litre of water at 20-day intervals, with a minimum of four applications, as part of its 2025 large-cardamom advisory.',
    5,
    4,
    'Medium',
    'Preventive',
    'ICAR Kharif Agro-Advisories 2025',
    NULL,
    NULL
),

-- 10. Harvest and post-harvest handling
(
    2,
    19,
    14,
    1,
    'Large cardamom capsules are ready for harvest and curing',
    'Harvest mature capsules carefully and dry them promptly after harvest. Use improved curing methods where available to preserve colour and aroma. After drying, remove tails, grade the capsules and store them in moisture-proof containers. Dried cardamom should have moisture content of not more than 10% for better shelf life.',
    5,
    4,
    'High',
    'Informational',
    'Agriculture Department, Government of Sikkim',
    NULL,
    NULL
);
SELECT *
FROM crop_advisory
WHERE crop_id = 3
ORDER BY advisory_id;
INSERT INTO crop_advisory
(
    crop_id,
    category_id,
    stage_id,
    trigger_type_id,
    trigger_condition,
    recommendation,
    district_id,
    season_id,
    priority,
    advisory_type,
    source,
    valid_from,
    valid_until
)
VALUES

-- 1. Land preparation, raised beds and drainage
(
    3,
    8,
    1,
    1,
    'Before planting ginger in the field',
    'Prepare raised beds across the slope where appropriate and provide adequate drainage to prevent water stagnation. Ginger is particularly vulnerable to rhizome and soft rot under poorly drained conditions. Use well-decomposed organic manure during land preparation.',
    5,
    1,
    'High',
    'Preventive',
    'ICAR Kharif Agro-Advisories 2025; Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 2. Healthy seed rhizomes
(
    3,
    4,
    2,
    1,
    'Selecting seed rhizomes before planting',
    'Select healthy, disease-free seed rhizomes from reliable planting material. Avoid rhizomes showing rot, discoloration, injury or other disease symptoms. Healthy rhizomes should have viable buds suitable for establishment.',
    5,
    1,
    'Critical',
    'Preventive',
    'ICAR Kharif Agro-Advisories 2025; Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 3. Seed-rhizome treatment
(
    3,
    4,
    2,
    1,
    'Before planting healthy ginger rhizomes',
    'Treat seed rhizomes before planting using an appropriate biological treatment such as Pseudomonas fluorescens or Trichoderma-based treatment according to locally recommended practice. Allow treated rhizomes to drain and dry appropriately before planting.',
    5,
    1,
    'High',
    'Preventive',
    'ICAR Kharif Agro-Advisories 2025; Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 4. Planting and establishment
(
    3,
    12,
    4,
    1,
    'During ginger planting',
    'Plant healthy rhizomes in shallow pits on prepared raised beds with viable buds facing upward. Maintain adequate spacing between plants and rows to allow proper development, aeration and intercultural operations. Ginger is commonly planted from late winter to spring in Sikkim conditions.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department, Government of Sikkim; ICAR Kharif Agro-Advisories 2025',
    NULL,
    NULL
),

-- 5. Mulching and moisture management
(
    3,
    13,
    7,
    2,
    'After planting and during periods of changing soil moisture',
    'Mulch ginger beds with suitable organic plant material after planting to conserve soil moisture, suppress weeds, reduce soil erosion and moderate soil temperature. Maintain adequate moisture but prevent prolonged water stagnation.',
    5,
    1,
    'High',
    'Preventive',
    'ICAR Kharif Agro-Advisories 2025; Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 6. Weed management and earthing
(
    3,
    17,
    7,
    7,
    'Weed growth during crop development',
    'Carry out timely hand weeding according to weed pressure. Earth up exposed rhizomes after weeding where necessary and maintain sufficient mulch. Good field sanitation also reduces places where pests and diseases can persist.',
    5,
    1,
    'Medium',
    'Preventive',
    'Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 7. Soft rot / rhizome rot
(
    3,
    16,
    7,
    4,
    'Lower leaves begin yellowing and pseudostems become soft or can be pulled out easily',
    'Inspect ginger fields frequently during wet periods for soft rot symptoms. Improve drainage immediately and prevent water stagnation. Uproot and safely dispose of infected plants and avoid spreading contaminated soil or planting material. Biological treatments such as Trichoderma and Pseudomonas may be used according to local recommendations.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department, Government of Sikkim; ICAR Kharif Agro-Advisories 2025',
    NULL,
    NULL
),

-- 8. Bacterial wilt
(
    3,
    16,
    7,
    4,
    'Yellowing, wilting and progressive drying of ginger plants or water-soaked rhizome symptoms',
    'Remove affected plants promptly and maintain strict field sanitation. Use only disease-free planting material, avoid moving contaminated soil or water between healthy and affected areas, and practise crop rotation with suitable non-host crops. Good drainage and preventive disease management are important.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 9. Shoot borer
(
    3,
    15,
    7,
    3,
    'Central shoots show boring damage, yellowing or drying',
    'Inspect plants regularly for shoot-borer damage. Remove and destroy severely affected shoots and maintain field sanitation. Neem-based or biological pest-management measures may be used as part of an integrated pest-management approach when infestation is detected.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department, Government of Sikkim; ICAR',
    NULL,
    NULL
),

-- 10. Harvest and storage
(
    3,
    19,
    14,
    1,
    'Ginger plants have reached harvest maturity',
    'Harvest ginger when the crop has reached the appropriate maturity for its intended use. Handle rhizomes carefully to avoid injuries, separate damaged or diseased rhizomes, and store only healthy, fully developed rhizomes under suitable conditions. Healthy, injury-free planting material should be selected for the next crop.',
    5,
    1,
    'High',
    'Informational',
    'Agriculture Department, Government of Sikkim',
    NULL,
    NULL
);
SELECT
    advisory_id,
    crop_id,
    category_id,
    stage_id,
    trigger_type_id,
    trigger_condition,
    district_id,
    season_id,
    priority,
    advisory_type,
    source
FROM crop_advisory
WHERE crop_id = 3
ORDER BY advisory_id;
SELECT COUNT(*) AS ginger_advisories
FROM crop_advisory
WHERE crop_id = 3;
SELECT *
FROM crop_advisory
WHERE crop_id = 4
ORDER BY advisory_id;
SELECT crop_id, crop_name
FROM crops
WHERE crop_id = 4;
INSERT INTO crop_advisory
(
    crop_id,
    category_id,
    stage_id,
    trigger_type_id,
    trigger_condition,
    recommendation,
    district_id,
    season_id,
    priority,
    advisory_type,
    source,
    valid_from,
    valid_until
)
VALUES

-- 1. Land preparation and drainage
(
    4,
    8,
    1,
    1,
    'Before planting turmeric',
    'Prepare well-drained raised or furrowed beds before planting. Ensure free movement of rainwater through drainage channels and avoid planting turmeric in fields where water stagnates. Thorough land preparation and good drainage help reduce rhizome-rot risk.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department, Government of Sikkim; ICAR Kharif Agro-Advisories 2025',
    NULL,
    NULL
),

-- 2. Healthy planting material
(
    4,
    16,
    2,
    1,
    'Selecting turmeric seed rhizomes',
    'Select healthy, disease-free mother rhizomes or finger rhizomes for planting. Do not use rhizomes showing rot, discoloration, injury or other disease symptoms. Disease-free planting material is important for preventing seed-borne disease.',
    5,
    1,
    'Critical',
    'Preventive',
    'Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 3. Rhizome treatment
(
    4,
    16,
    2,
    1,
    'Before planting seed rhizomes',
    'Treat seed rhizomes before planting using an appropriate locally recommended treatment. The Sikkim Agriculture Department recommends Bordeaux mixture treatment for rhizome-rot prevention, while Trichoderma-based rhizome treatment is recommended for leaf-blight management.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 4. Planting and spacing
(
    4,
    12,
    4,
    1,
    'During turmeric planting',
    'Plant healthy whole or split rhizomes on prepared raised beds with the buds facing upward. Maintain approximately 45–60 cm between rows and 15–20 cm between plants under the Sikkim cultivation guidance. Cover planted rhizomes properly with soil and organic material.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department, Government of Sikkim; ICAR Kharif Agro-Advisories 2025',
    NULL,
    NULL
),

-- 5. Mulching and moisture management
(
    4,
    13,
    7,
    2,
    'After planting and during crop growth',
    'Mulch turmeric beds with suitable organic material soon after planting to conserve soil moisture, suppress weeds and reduce soil erosion. Maintain adequate moisture while ensuring excess rainwater drains away quickly.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department, Government of Sikkim; ICAR Kharif Agro-Advisories 2025',
    NULL,
    NULL
),

-- 6. Weed and field sanitation
(
    4,
    17,
    7,
    7,
    'Weed growth or excessive plant debris in the turmeric field',
    'Keep the field clean through timely weeding and removal of diseased plant material. Maintain mulch after weeding where appropriate. Good field sanitation reduces sources of disease and competition for crop resources.',
    5,
    1,
    'Medium',
    'Preventive',
    'Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 7. Rhizome rot
(
    4,
    16,
    7,
    4,
    'Lower leaves yellow and rhizomes show brown, water-soaked or rotting tissue',
    'Inspect turmeric regularly during wet conditions. Remove infected clumps from the field and improve drainage immediately. Avoid using infected rhizomes as planting material. Crop rotation and appropriate soil or rhizome treatment should be used as part of disease management.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department, Government of Sikkim; ICAR Kharif Agro-Advisories 2025',
    NULL,
    NULL
),

-- 8. Leaf blight
(
    4,
    16,
    7,
    4,
    'Water-soaked spots and progressive blighting appear on turmeric leaves',
    'Inspect leaves regularly, particularly under moist conditions. Remove severely affected plant material, maintain field sanitation and use disease-free planting material. Biological treatments such as Trichoderma may be incorporated into disease-management practices according to local recommendations.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 9. Leaf spot and leaf blotch
(
    4,
    16,
    7,
    4,
    'Brown spots or blotches appear on turmeric leaves during humid weather',
    'Monitor the crop for leaf spot and leaf blotch, particularly during August to November. Maintain field sanitation, avoid excessive shading and use crop rotation where appropriate. Disease-management sprays should only be used according to locally approved recommendations and label directions.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department, Government of Sikkim',
    NULL,
    NULL
),

-- 10. Harvest and post-harvest handling
(
    4,
    19,
    14,
    1,
    'Turmeric crop has reached harvest maturity',
    'Turmeric is generally ready for harvesting about 9–11 months after planting, depending on variety. Harvest mature rhizomes carefully, wash and clean them properly, and separate damaged or diseased rhizomes. For dry turmeric, properly dry the cleaned rhizomes before storage or processing.',
    5,
    1,
    'High',
    'Informational',
    'Agriculture Department, Government of Sikkim',
    NULL,
    NULL
);
SELECT
    advisory_id,
    crop_id,
    category_id,
    stage_id,
    trigger_type_id,
    trigger_condition,
    district_id,
    season_id,
    priority,
    advisory_type,
    source
FROM crop_advisory
WHERE crop_id = 4
ORDER BY advisory_id;
SELECT COUNT(*) AS turmeric_advisories
FROM crop_advisory
WHERE crop_id = 4;
SELECT *
FROM crop_advisory
WHERE crop_id = 5
ORDER BY advisory_id;
SELECT crop_id, crop_name
FROM crops
WHERE crop_id = 5;
INSERT INTO crop_advisory
(
    crop_id,
    category_id,
    stage_id,
    trigger_type_id,
    trigger_condition,
    recommendation,
    district_id,
    season_id,
    priority,
    advisory_type,
    source,
    valid_from,
    valid_until
)
VALUES

-- 1. Land preparation and drainage
(
    5,
    8,
    1,
    1,
    'Before planting French bean',
    'Prepare loose, fertile and well-drained soil before planting. Ensure that excess rainwater can drain freely from the field, particularly in the hilly areas of Darjeeling. Avoid planting French bean in locations where water stagnates.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 2. Healthy seed selection
(
    5,
    16,
    2,
    1,
    'Selecting French bean seed',
    'Select clean, healthy and disease-free French bean seeds for planting. Avoid seeds that are shrivelled, damaged, discoloured or affected by visible disease symptoms. Good quality seed supports uniform germination and healthy crop establishment.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 3. Seed treatment
(
    5,
    16,
    2,
    1,
    'Before planting French bean seed',
    'Use an appropriate locally recommended seed treatment before planting to reduce the risk of seed-borne and soil-borne diseases. Biological seed treatments may be preferred where suitable under local cultivation practices.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 4. Sowing and spacing
(
    5,
    12,
    4,
    1,
    'During French bean planting',
    'Sow French bean in well-prepared soil with adequate spacing between plants and rows to allow proper air circulation and field operations. Avoid very dense planting because excessive humidity within the crop canopy can encourage disease development.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 5. Moisture and irrigation management
(
    5,
    13,
    7,
    2,
    'After planting and during French bean crop growth',
    'Maintain adequate and uniform soil moisture during germination, flowering and pod formation. Avoid excessive irrigation and water stagnation, especially during periods of heavy rainfall. Provide drainage channels where necessary.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 6. Weed and field sanitation
(
    5,
    17,
    7,
    7,
    'Weed growth or diseased plant material in the French bean field',
    'Remove weeds regularly and maintain good field sanitation. Remove severely diseased or dead plant material from the field rather than allowing it to remain around healthy plants. Proper sanitation reduces pest and disease pressure.',
    5,
    1,
    'Medium',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 7. Aphid infestation
(
    5,
    15,
    7,
    4,
    'Clusters of small insects appear on young French bean shoots, leaves or tender plant parts',
    'Inspect young shoots and leaves regularly for aphids. Remove heavily infested plant parts where practical and encourage beneficial insects. If infestation becomes severe, use only locally approved pest-management measures according to recommended directions.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 8. Bean fly / stem damage
(
    5,
    15,
    6,
    4,
    'Young French bean plants show wilting, yellowing or damage around the stem',
    'Inspect young plants regularly for symptoms of bean fly attack. Remove and destroy severely affected plants where appropriate and maintain field sanitation. Early detection and removal of affected plants can help reduce pest spread.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 9. Root rot and excessive moisture
(
    5,
    16,
    7,
    4,
    'French bean plants wilt and roots show brown or rotting tissue, particularly after prolonged wet conditions',
    'Improve field drainage immediately and prevent water stagnation. Remove severely affected plants and avoid using seed from diseased crops. Use healthy planting material and appropriate locally recommended disease-management practices to reduce root-rot risk.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 10. Harvesting tender pods
(
    5,
    19,
    14,
    1,
    'French bean pods have reached marketable tenderness',
    'Harvest French bean pods while they are young, tender and suitable for consumption. Regular harvesting prevents pods from becoming fibrous and encourages continued production. Handle harvested pods carefully to avoid bruising and quality loss.',
    5,
    1,
    'High',
    'Informational',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
);
SELECT *
FROM crop_advisory
WHERE crop_id = 5
ORDER BY advisory_id;
SELECT crop_id, crop_name
FROM crops
WHERE crop_id = 5;
SELECT COUNT(*) AS french_bean_advisories
FROM crop_advisory
WHERE crop_id = 5;
INSERT INTO crop_advisory
(
    crop_id,
    category_id,
    stage_id,
    trigger_type_id,
    trigger_condition,
    recommendation,
    district_id,
    season_id,
    priority,
    advisory_type,
    source,
    valid_from,
    valid_until
)
VALUES

-- 1. Land preparation and drainage
(
    6,
    8,
    1,
    1,
    'Before planting potato',
    'Prepare loose, friable and well-drained soil before planting. Ensure excess rainwater can drain freely, particularly on sloping land in Darjeeling. Avoid planting potato in fields where water stagnates.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 2. Healthy seed tubers
(
    6,
    16,
    2,
    1,
    'Selecting potato seed tubers',
    'Select healthy, disease-free and properly developed seed tubers from a reliable source. Avoid tubers showing rot, cuts, excessive sprouting, discoloration or other disease symptoms. Healthy planting material is important for uniform crop establishment.',
    5,
    1,
    'Critical',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 3. Seed tuber treatment
(
    6,
    16,
    2,
    1,
    'Before planting potato seed tubers',
    'Use healthy seed tubers and follow locally recommended seed treatment practices where required. Allow cut seed pieces to heal properly before planting and avoid planting damaged or rotting tubers.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 4. Planting and spacing
(
    6,
    12,
    4,
    1,
    'During potato planting',
    'Plant healthy seed tubers at suitable depth and spacing in well-prepared soil. Maintain adequate spacing between rows and plants to allow proper tuber development, earthing-up and field operations. Avoid planting too deeply in heavy or poorly drained soil.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 5. Irrigation and moisture management
(
    6,
    13,
    7,
    2,
    'Potato crop is experiencing dry soil or prolonged wet conditions',
    'Maintain adequate soil moisture during crop establishment, tuber initiation and tuber development. Avoid excessive irrigation and water stagnation because prolonged wetness can increase the risk of tuber and root diseases.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 6. Earthing up and weed management
(
    6,
    17,
    7,
    7,
    'Weed growth or exposed potato tubers observed',
    'Keep the field free from excessive weeds and carry out timely earthing-up. Maintain sufficient soil cover over developing tubers to protect them from sunlight, greening and physical damage.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 7. Late blight
(
    6,
    16,
    7,
    4,
    'Dark water-soaked lesions appear on potato leaves during cool and humid weather',
    'Inspect potato plants regularly during cool, humid and wet weather for signs of late blight. Remove severely affected plant material where practical and improve field aeration and drainage. If disease pressure becomes high, follow locally approved fungicide recommendations and label directions.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 8. Early blight
(
    6,
    16,
    7,
    4,
    'Brown circular spots with concentric rings appear on older potato leaves',
    'Monitor older leaves for early blight symptoms and maintain good field sanitation. Avoid prolonged leaf wetness and remove severely affected plant material where appropriate. Use locally approved disease-management measures when necessary.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 9. Potato tuber damage and rot
(
    6,
    16,
    13,
    4,
    'Potato tubers show rotting, lesions or damage before harvest',
    'Maintain proper drainage and avoid harvesting or handling tubers under excessively wet conditions. Remove damaged or diseased tubers and do not store infected potatoes with healthy produce. Handle tubers carefully to prevent wounds that can lead to storage rot.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 10. Harvest and post-harvest handling
(
    6,
    19,
    14,
    1,
    'Potato crop has reached harvest maturity',
    'Harvest potato when the crop has reached maturity and the foliage has naturally senesced or according to the recommended production schedule. Avoid unnecessary injury to tubers during digging. Dry and grade harvested tubers properly, remove damaged or diseased tubers and store healthy potatoes in a cool, dry and well-ventilated location.',
    5,
    1,
    'High',
    'Informational',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
);
SELECT COUNT(*) AS potato_advisories
FROM crop_advisory
WHERE crop_id = 6;
INSERT INTO crop_advisory
(
    crop_id,
    category_id,
    stage_id,
    trigger_type_id,
    trigger_condition,
    recommendation,
    district_id,
    season_id,
    priority,
    advisory_type,
    source,
    valid_from,
    valid_until
)
VALUES

-- 1. Land preparation
(
    7,
    8,
    1,
    1,
    'Before planting maize',
    'Prepare a loose, fertile and well-drained seedbed before planting. On sloping land, follow suitable soil and water conservation practices to reduce erosion and retain soil moisture. Avoid fields where water stagnates.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 2. Healthy seed selection
(
    7,
    16,
    2,
    1,
    'Selecting maize seed',
    'Use clean, healthy and good-quality maize seed from a reliable source. Avoid damaged, discoloured or visibly diseased seed. Good quality seed supports uniform germination and healthy crop establishment.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 3. Seed treatment
(
    7,
    16,
    2,
    1,
    'Before planting maize seed',
    'Treat maize seed using an appropriate locally recommended seed treatment to reduce seed-borne and soil-borne disease risks. Biological seed treatments may be used where suitable and locally recommended.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 4. Sowing and spacing
(
    7,
    12,
    4,
    1,
    'During maize planting',
    'Sow maize at suitable depth and maintain adequate spacing between rows and plants. Proper spacing allows good sunlight penetration, air circulation and root development while reducing excessive competition between plants.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 5. Moisture management
(
    7,
    13,
    7,
    2,
    'Maize crop is exposed to dry soil or excessive rainfall',
    'Maintain adequate soil moisture during germination, vegetative growth, flowering and grain formation. Avoid prolonged waterlogging and provide drainage during heavy rainfall. Protect soil moisture through suitable mulching and conservation practices where appropriate.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 6. Weed management
(
    7,
    17,
    7,
    7,
    'Heavy weed growth appears in the maize field',
    'Control weeds during the early growth stages of maize because weeds compete strongly for moisture, nutrients and sunlight. Carry out timely hand weeding or other locally suitable weed-management practices while avoiding damage to maize roots.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 7. Fall armyworm
(
    7,
    15,
    7,
    4,
    'Window-like leaf damage, ragged feeding or caterpillars observed inside the maize whorl',
    'Inspect maize plants regularly, particularly the whorl, for fall armyworm damage. Collect and destroy larvae where practical and maintain field monitoring. If infestation becomes severe, use only locally approved management measures according to recommended directions.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 8. Stem borer
(
    7,
    15,
    7,
    4,
    'Dead hearts, stem tunnelling or broken maize plants observed',
    'Inspect plants for stem-borer symptoms such as dead hearts, bore holes and frass. Remove severely affected plants where practical and maintain field sanitation. Follow locally recommended integrated pest-management practices when infestation is significant.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 9. Leaf disease management
(
    7,
    16,
    7,
    4,
    'Brown, grey or elongated lesions appear on maize leaves under humid conditions',
    'Monitor maize leaves regularly for disease symptoms, especially during prolonged humid or wet weather. Maintain adequate plant spacing and field sanitation and remove severely affected plant material where appropriate. Use locally approved disease-management measures when necessary.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 10. Harvest and post-harvest handling
(
    7,
    19,
    14,
    1,
    'Maize crop has reached harvest maturity',
    'Harvest maize when the cobs and grains have reached appropriate maturity. Dry the harvested cobs or grain properly before storage, remove damaged or diseased material and protect stored grain from excess moisture, insects and rodents.',
    5,
    1,
    'High',
    'Informational',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
);
INSERT INTO crop_advisory
(
    crop_id,
    category_id,
    stage_id,
    trigger_type_id,
    trigger_condition,
    recommendation,
    district_id,
    season_id,
    priority,
    advisory_type,
    source,
    valid_from,
    valid_until
)
VALUES

-- 1. Nursery and land preparation
(
    8,
    8,
    3,
    1,
    'Before raising rice nursery',
    'Select a fertile, well-drained nursery area with reliable access to water. Prepare a fine seedbed and ensure excess water can be drained after heavy rainfall. Use healthy seed to establish a vigorous nursery.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 2. Healthy seed selection
(
    8,
    16,
    2,
    1,
    'Selecting rice seed',
    'Use clean, healthy and good-quality rice seed from a reliable source. Avoid seed that is damaged, discoloured or affected by visible disease symptoms. Good seed quality improves germination and uniform crop establishment.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 3. Seed treatment
(
    8,
    16,
    2,
    1,
    'Before sowing rice seed',
    'Treat rice seed using an appropriate locally recommended seed treatment to reduce seed-borne disease and improve crop establishment. Biological treatments may be used where suitable under local cultivation practices.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 4. Transplanting
(
    8,
    12,
    4,
    1,
    'Rice seedlings are ready for transplanting',
    'Transplant healthy, vigorous seedlings into properly prepared soil. Maintain suitable spacing and avoid excessively deep planting. Timely transplanting and proper spacing support good tillering and reduce unnecessary competition between plants.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 5. Water management
(
    8,
    13,
    7,
    2,
    'Rice field has excessive standing water or insufficient moisture',
    'Maintain appropriate soil moisture according to crop stage and local field conditions. Avoid unnecessary prolonged standing water and drain excess rainwater promptly, particularly in areas affected by heavy monsoon rainfall.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 6. Weed management
(
    8,
    17,
    7,
    7,
    'Heavy weed growth appears in the rice field',
    'Control weeds during the early crop-growth period because they compete with rice for nutrients, moisture and sunlight. Use timely hand weeding or other locally suitable weed-management practices while avoiding damage to rice seedlings.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 7. Stem borer
(
    8,
    15,
    8,
    4,
    'Dead hearts or white ears appear in rice plants',
    'Inspect rice plants regularly for stem-borer symptoms such as dead hearts during vegetative growth and white ears near heading. Remove severely affected plant material where practical and follow locally recommended integrated pest-management practices when infestation becomes significant.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 8. Rice blast
(
    8,
    16,
    7,
    4,
    'Spindle-shaped brown or grey lesions appear on rice leaves',
    'Monitor rice plants for blast symptoms, particularly during humid and cool conditions. Maintain proper field management and avoid excessive nitrogen application. Remove severely affected material where practical and use locally approved disease-management measures when necessary.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 9. Brown planthopper
(
    8,
    15,
    8,
    4,
    'Rice plants show yellowing, wilting or hopper burn near the base',
    'Inspect the lower portions of rice plants for planthoppers, particularly where the crop canopy is dense. Avoid unnecessary insecticide use that can destroy beneficial insects. Maintain balanced crop nutrition and follow locally recommended integrated pest-management measures if infestation is confirmed.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 10. Harvest and post-harvest handling
(
    8,
    19,
    14,
    1,
    'Rice crop has reached harvest maturity',
    'Harvest rice when grains have reached appropriate maturity and most panicles have changed colour. Avoid unnecessary delay after maturity. Dry harvested grain properly before storage and remove damaged, diseased or contaminated grain to maintain quality.',
    5,
    1,
    'High',
    'Informational',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
);
INSERT INTO crop_advisory
(
    crop_id,
    category_id,
    stage_id,
    trigger_type_id,
    trigger_condition,
    recommendation,
    district_id,
    season_id,
    priority,
    advisory_type,
    source,
    valid_from,
    valid_until
)
VALUES

-- 1. Orchard site selection and drainage
(
    9,
    8,
    1,
    1,
    'Before establishing an orange orchard',
    'Select a well-drained site with good sunlight and adequate air circulation. Avoid poorly drained locations where water stagnates. On sloping land, maintain suitable soil and water conservation measures to reduce erosion while allowing excess rainwater to drain safely.',
    5,
    1,
    'Critical',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 2. Healthy planting material
(
    9,
    16,
    3,
    1,
    'Selecting orange planting material',
    'Use healthy, vigorous and disease-free grafted or nursery plants from a reliable source. Avoid plants showing yellowing, root damage, abnormal growth or visible pest and disease symptoms. Healthy planting material is essential for establishing a productive orchard.',
    5,
    1,
    'Critical',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 3. Orchard planting and spacing
(
    9,
    12,
    4,
    1,
    'During orange orchard planting',
    'Plant healthy orange trees in properly prepared pits with adequate spacing for the selected variety and local growing conditions. Maintain sufficient space for sunlight penetration, air circulation, root development and future orchard operations.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 4. Soil moisture and mulching
(
    9,
    13,
    7,
    2,
    'Orange trees experience dry soil or excessive rainfall',
    'Maintain adequate soil moisture, particularly during flowering, fruit development and prolonged dry periods. Use suitable organic mulch around the tree basin while keeping mulch away from direct contact with the trunk. Ensure excess monsoon rain drains away quickly.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 5. Nutrient and organic matter management
(
    9,
    13,
    7,
    1,
    'Orange trees show weak growth or poor fruit development',
    'Maintain soil fertility through well-decomposed organic manure or compost and balanced nutrient management based on soil and plant requirements. Avoid excessive fertilizer application. Regular addition of organic matter can improve soil structure and moisture retention.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 6. Citrus psylla and sap-sucking pests
(
    9,
    15,
    7,
    4,
    'Young orange shoots show curling, distortion or clusters of small sap-sucking insects',
    'Inspect new flushes regularly for citrus psylla and other sap-sucking pests. Remove badly affected shoots where practical and encourage beneficial insects. If infestation becomes significant, use only locally approved pest-management measures according to recommended directions.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 7. Citrus leaf miner
(
    9,
    15,
    7,
    4,
    'Silvery winding mines or distorted young leaves appear on new orange flush',
    'Monitor young leaves during periods of active flushing for citrus leaf miner damage. Avoid unnecessary insecticide applications that may harm beneficial organisms. Maintain healthy new growth and follow locally recommended integrated pest-management practices when infestation is severe.',
    5,
    1,
    'Medium',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 8. Citrus canker and leaf disease
(
    9,
    16,
    7,
    4,
    'Raised brown lesions or abnormal spots appear on orange leaves, shoots or fruits',
    'Inspect the orchard regularly for citrus canker and other leaf diseases, particularly during humid and rainy conditions. Remove severely affected plant material, maintain orchard sanitation and avoid unnecessary injury to trees. Use locally approved disease-management measures when required.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 9. Fruit drop and orchard sanitation
(
    9,
    17,
    10,
    4,
    'Premature fruit drop or diseased fruits are observed',
    'Inspect trees regularly during fruit development and remove fallen, damaged or diseased fruits from the orchard. Maintain balanced moisture and nutrition and avoid waterlogging. Investigate persistent fruit drop for pest, disease, nutrient or environmental causes before applying corrective measures.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 10. Harvest and post-harvest handling
(
    9,
    19,
    14,
    1,
    'Orange fruits have reached appropriate maturity',
    'Harvest mature fruits carefully without damaging the rind, branches or fruiting shoots. Avoid pulling fruits forcefully from the tree. Sort harvested fruits and remove damaged or diseased produce before packing, transport or storage.',
    5,
    1,
    'High',
    'Informational',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
);
INSERT INTO crop_advisory
(
    crop_id,
    category_id,
    stage_id,
    trigger_type_id,
    trigger_condition,
    recommendation,
    district_id,
    season_id,
    priority,
    advisory_type,
    source,
    valid_from,
    valid_until
)
VALUES

-- 1. Nursery and soil preparation
(
    10,
    8,
    3,
    1,
    'Before raising cabbage nursery',
    'Prepare a fertile, loose and well-drained nursery bed. Choose a site with good sunlight and avoid areas where water stagnates. Use clean soil and healthy planting material to establish vigorous seedlings.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 2. Healthy seed selection
(
    10,
    16,
    2,
    1,
    'Selecting cabbage seed',
    'Use clean, healthy and good-quality cabbage seed from a reliable source. Avoid damaged, discoloured or visibly diseased seed. Healthy seed supports uniform germination and reduces the risk of seed-borne problems.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 3. Seedling management
(
    10,
    16,
    3,
    1,
    'Cabbage seedlings are developing in the nursery',
    'Maintain adequate moisture without waterlogging and provide sufficient sunlight and ventilation. Remove weak or diseased seedlings and avoid excessive crowding. Harden healthy seedlings gradually before transplanting them to the main field.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 4. Transplanting and spacing
(
    10,
    12,
    4,
    1,
    'Cabbage seedlings are ready for transplanting',
    'Transplant healthy, vigorous seedlings into well-prepared soil at suitable spacing for the selected variety. Avoid excessively deep planting and provide adequate space for head development and air circulation.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 5. Moisture and nutrient management
(
    10,
    13,
    7,
    2,
    'Cabbage crop experiences dry soil or excessive rainfall',
    'Maintain uniform soil moisture during vegetative growth and head formation. Avoid prolonged waterlogging and drain excess rainwater promptly. Apply well-decomposed organic manure or compost and maintain balanced nutrition according to soil and crop requirements.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 6. Weed management
(
    10,
    17,
    7,
    7,
    'Heavy weed growth appears around cabbage plants',
    'Keep the cabbage field free from excessive weeds, particularly during early crop growth. Carry out timely hand weeding or other locally suitable weed-management practices while avoiding damage to cabbage roots.',
    5,
    1,
    'Medium',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 7. Diamondback moth and caterpillar pests
(
    10,
    15,
    7,
    4,
    'Cabbage leaves show holes, windowing or caterpillars are observed',
    'Inspect leaves regularly for diamondback moth, cabbage caterpillars and other defoliating pests. Collect and destroy caterpillars or heavily infested leaves where practical and encourage natural enemies. Use locally approved pest-management measures only when infestation becomes significant.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 8. Aphids
(
    10,
    15,
    7,
    4,
    'Clusters of small insects appear on young cabbage leaves or growing points',
    'Monitor cabbage plants regularly for aphids, particularly on tender leaves and growing points. Remove heavily infested plant parts where practical and conserve beneficial insects. If infestation becomes severe, follow locally recommended integrated pest-management practices.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 9. Black rot and other leaf diseases
(
    10,
    16,
    7,
    4,
    'Yellowing, V-shaped leaf lesions or dark veins appear on cabbage leaves',
    'Inspect cabbage plants for symptoms of black rot and other bacterial or fungal diseases, particularly under warm and humid conditions. Remove severely affected plants, maintain field sanitation and avoid overhead irrigation where possible. Use disease-free seed and locally approved disease-management measures.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 10. Harvest and post-harvest handling
(
    10,
    19,
    14,
    1,
    'Cabbage heads have reached harvest maturity',
    'Harvest cabbage when heads are firm and have reached the desired market size. Cut heads carefully with a clean tool while retaining suitable outer leaves for protection. Remove damaged or diseased heads and keep harvested produce shaded and cool to reduce quality loss.',
    5,
    1,
    'High',
    'Informational',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
);
INSERT INTO crop_advisory
(
    crop_id,
    category_id,
    stage_id,
    trigger_type_id,
    trigger_condition,
    recommendation,
    district_id,
    season_id,
    priority,
    advisory_type,
    source,
    valid_from,
    valid_until
)
VALUES

-- 1. Nursery and soil preparation
(
    11,
    8,
    3,
    1,
    'Before raising cauliflower nursery',
    'Prepare a fertile, loose and well-drained nursery bed in a location with good sunlight. Avoid areas where water stagnates. Use clean soil and healthy seed to establish vigorous seedlings.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 2. Healthy seed selection
(
    11,
    16,
    2,
    1,
    'Selecting cauliflower seed',
    'Use clean, healthy and good-quality cauliflower seed from a reliable source. Avoid damaged, discoloured or visibly diseased seed. Good-quality seed supports uniform germination and healthy crop establishment.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 3. Seedling management
(
    11,
    16,
    3,
    1,
    'Cauliflower seedlings are developing in the nursery',
    'Maintain adequate moisture without waterlogging and provide good sunlight and ventilation. Remove weak or diseased seedlings and avoid excessive crowding. Harden healthy seedlings before transplanting them to the main field.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 4. Transplanting and spacing
(
    11,
    12,
    4,
    1,
    'Cauliflower seedlings are ready for transplanting',
    'Transplant healthy, vigorous seedlings into well-prepared soil at spacing suitable for the variety. Avoid excessively deep planting and provide adequate space for curd development and air circulation.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 5. Moisture and nutrient management
(
    11,
    13,
    7,
    2,
    'Cauliflower crop experiences dry soil or excessive rainfall',
    'Maintain uniform soil moisture during vegetative growth and curd formation. Avoid prolonged waterlogging and drain excess rainwater promptly. Use well-decomposed organic manure or compost and maintain balanced nutrition according to soil and crop requirements.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 6. Weed management
(
    11,
    17,
    7,
    7,
    'Heavy weed growth appears around cauliflower plants',
    'Keep the cauliflower field free from excessive weeds, particularly during early crop growth. Carry out timely hand weeding or other locally suitable practices while avoiding damage to shallow cauliflower roots.',
    5,
    1,
    'Medium',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 7. Diamondback moth and caterpillar pests
(
    11,
    15,
    7,
    4,
    'Cauliflower leaves show holes, windowing or caterpillars are observed',
    'Inspect leaves regularly for diamondback moth, cabbage caterpillars and other defoliating pests. Collect and destroy caterpillars or heavily affected plant parts where practical and conserve natural enemies. Use locally approved pest-management measures only when infestation becomes significant.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 8. Aphids
(
    11,
    15,
    7,
    4,
    'Clusters of small insects appear on young cauliflower leaves or growing points',
    'Monitor cauliflower plants regularly for aphids, particularly on tender leaves and growing points. Remove heavily infested plant parts where practical and encourage beneficial insects. Follow locally recommended integrated pest-management measures if infestation becomes severe.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 9. Downy mildew and leaf disease
(
    11,
    16,
    7,
    4,
    'Yellow or pale patches and fungal growth appear on cauliflower leaves during cool and humid weather',
    'Monitor the crop for downy mildew and other leaf diseases, especially during cool, humid and wet conditions. Maintain adequate spacing and field sanitation, avoid prolonged leaf wetness and remove severely affected plant material where appropriate. Use locally approved disease-management measures when necessary.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 10. Curd protection and harvesting
(
    11,
    19,
    14,
    1,
    'Cauliflower curd has reached harvest maturity',
    'Harvest cauliflower when the curd is firm, compact and has reached the appropriate market size. Avoid delaying harvest because curds may become loose or discoloured. Protect harvested curds from direct sunlight and handle them carefully to maintain freshness and quality.',
    5,
    1,
    'High',
    'Informational',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
);
INSERT INTO crop_advisory
(
    crop_id,
    category_id,
    stage_id,
    trigger_type_id,
    trigger_condition,
    recommendation,
    district_id,
    season_id,
    priority,
    advisory_type,
    source,
    valid_from,
    valid_until
)
VALUES

-- 1. Nursery and soil preparation
(
    12,
    8,
    3,
    1,
    'Before raising tomato nursery',
    'Prepare a fertile, loose and well-drained nursery bed in a location receiving adequate sunlight. Protect the nursery from excessive rainfall and waterlogging. Use clean growing material and healthy seed to produce vigorous seedlings.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 2. Healthy seed selection
(
    12,
    16,
    2,
    1,
    'Selecting tomato seed',
    'Use clean, healthy and good-quality tomato seed from a reliable source. Prefer varieties suited to the local climate and production conditions. Avoid damaged, discoloured or visibly diseased seed.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 3. Seedling management
(
    12,
    16,
    3,
    1,
    'Tomato seedlings are developing in the nursery',
    'Maintain adequate moisture without waterlogging and provide good ventilation and sunlight. Avoid excessive crowding and remove weak or diseased seedlings. Harden healthy seedlings before transplanting them into the main field.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 4. Transplanting and spacing
(
    12,
    12,
    4,
    1,
    'Tomato seedlings are ready for transplanting',
    'Transplant healthy, vigorous seedlings into well-prepared, well-drained soil. Maintain spacing appropriate for the variety and provide sufficient room for air circulation and plant growth. Avoid planting in areas prone to water stagnation.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 5. Moisture and nutrient management
(
    12,
    13,
    7,
    2,
    'Tomato crop experiences dry soil or excessive rainfall',
    'Maintain uniform soil moisture during vegetative growth, flowering and fruit development. Avoid irregular irrigation and prolonged waterlogging. Apply well-decomposed organic manure or compost and maintain balanced nutrition according to soil and crop requirements.',
    5,
    1,
    'High',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 6. Weed management and field sanitation
(
    12,
    17,
    7,
    7,
    'Heavy weed growth or diseased plant debris is present in the tomato field',
    'Control weeds regularly and remove diseased leaves, fruits and plant debris from the field. Maintain good sanitation around tomato plants to reduce pest and disease pressure. Avoid damaging plant stems and roots during weeding.',
    5,
    1,
    'Medium',
    'Preventive',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 7. Fruit borer
(
    12,
    15,
    9,
    4,
    'Small holes, feeding damage or caterpillars are observed on tomato fruits',
    'Inspect tomato plants regularly for fruit borer damage, particularly during flowering and fruit development. Remove and destroy affected fruits and visible caterpillars where practical. Encourage natural enemies and use locally approved pest-management measures when infestation becomes significant.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 8. Aphids and whiteflies
(
    12,
    15,
    7,
    4,
    'Clusters of small insects are observed on young tomato leaves or shoots',
    'Monitor young shoots and the underside of leaves for aphids, whiteflies and other sap-sucking pests. Remove heavily infested plant parts where practical and conserve beneficial insects. If infestation becomes severe, follow locally recommended integrated pest-management practices.',
    5,
    1,
    'High',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 9. Late blight and leaf diseases
(
    12,
    16,
    7,
    4,
    'Dark water-soaked lesions or rapid leaf blighting appear during cool and humid weather',
    'Inspect tomato plants frequently during cool, humid and wet conditions for late blight and other fungal diseases. Remove severely affected plant material, improve air circulation and avoid prolonged leaf wetness. Use locally approved disease-management measures when required.',
    5,
    1,
    'Critical',
    'Corrective',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
),

-- 10. Harvest and post-harvest handling
(
    12,
    19,
    14,
    1,
    'Tomato fruits have reached the appropriate maturity stage',
    'Harvest tomato fruits at the maturity stage required for the intended market and transport distance. Pick fruits carefully without damaging the plants. Remove cracked, bruised or diseased fruits and keep harvested produce shaded and well ventilated to reduce quality loss.',
    5,
    1,
    'High',
    'Informational',
    'Agriculture Department; ICAR agricultural advisories',
    NULL,
    NULL
);
SELECT
    c.crop_id,
    c.crop_name,
    COUNT(cpg.guide_id) AS guide_count
FROM crops c
LEFT JOIN crop_production_guides cpg
    ON c.crop_id = cpg.crop_id
GROUP BY c.crop_id, c.crop_name
ORDER BY c.crop_id;

