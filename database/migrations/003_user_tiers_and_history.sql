-- ========================================================================
-- 003: User Profiles, Tier Quotas, and Multi-Turn Chat History
-- ========================================================================

-- 1. Users Table (Captured from WhatsApp phone or web)
CREATE TABLE IF NOT EXISTS users (
    user_id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(255),
    location VARCHAR(255),
    user_type VARCHAR(50) NOT NULL DEFAULT 'Free',
    onboarding_step VARCHAR(50) NOT NULL DEFAULT 'ask_name',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. User Tiers Table (Quotas & History Memory Depth)
CREATE TABLE IF NOT EXISTS user_tiers (
    user_type VARCHAR(50) PRIMARY KEY,
    daily_token_limit INT NOT NULL,
    max_history_messages INT NOT NULL DEFAULT 6,
    description TEXT
);

-- Seed initial tier limits
INSERT INTO user_tiers (user_type, daily_token_limit, max_history_messages, description) VALUES
('Free', 10000, 6, 'Free plan with 10k daily tokens and 3-turn memory (~6 messages)'),
('Pro', 50000, 10, 'Pro farmer plan with 50k daily tokens and 5-turn memory (~10 messages)'),
('Ultra', 200000, 16, 'Ultra farmer plan with 200k daily tokens and 8-turn memory (~16 messages)'),
('FPOHead', 500000, 20, 'FPO Lead plan with 500k daily tokens and 10-turn memory (~20 messages)')
ON CONFLICT (user_type) DO NOTHING;

-- 3. Daily Token Usage Table
CREATE TABLE IF NOT EXISTS daily_token_usage (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(32) NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    usage_date DATE NOT NULL DEFAULT CURRENT_DATE,
    tokens_used INT NOT NULL DEFAULT 0,
    request_count INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, usage_date)
);

CREATE INDEX IF NOT EXISTS idx_token_usage_lookup ON daily_token_usage(user_id, usage_date);

-- 4. Chat History Table (Sliding Window Memory)
CREATE TABLE IF NOT EXISTS chat_history (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(32) NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    tokens INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_chat_history_user ON chat_history(user_id, created_at DESC);
