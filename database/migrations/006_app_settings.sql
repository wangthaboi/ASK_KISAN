-- ========================================================================
-- 006: Application Settings (Dynamic LLM Fallback & Config Flags)
-- ========================================================================

CREATE TABLE IF NOT EXISTS app_settings (
    key VARCHAR(64) PRIMARY KEY,
    value VARCHAR(255) NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Seed default settings
INSERT INTO app_settings (key, value, description) VALUES
('enable_groq_fallback', 'true', 'Enable automatic fallback to Groq when Gemini rate limits or credits are exhausted'),
('primary_llm_provider', 'gemini', 'Primary LLM provider to use for chat and advisories (gemini or groq)')
ON CONFLICT (key) DO NOTHING;
