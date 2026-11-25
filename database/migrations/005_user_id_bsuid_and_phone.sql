-- ========================================================================
-- 005: WhatsApp BSUID Support and Phone Number Mapping
-- ========================================================================

-- Widen user_id column across users, token usage, and chat history
ALTER TABLE users ALTER COLUMN user_id TYPE VARCHAR(128);
ALTER TABLE daily_token_usage ALTER COLUMN user_id TYPE VARCHAR(128);
ALTER TABLE chat_history ALTER COLUMN user_id TYPE VARCHAR(128);

-- Add optional phone_number column for phone-to-BSUID lookup
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number VARCHAR(32);
CREATE INDEX IF NOT EXISTS idx_users_phone_number ON users(phone_number);
