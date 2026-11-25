-- ========================================================================
-- 004: User Profile Updates (One-Time Name Change & Flexible Location)
-- ========================================================================

ALTER TABLE users ADD COLUMN IF NOT EXISTS name_changes_count INT NOT NULL DEFAULT 0;
