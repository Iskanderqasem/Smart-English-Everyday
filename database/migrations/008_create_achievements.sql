-- Migration: 008_create_achievements.sql
-- Description: Achievements/badges table and user_achievements junction
-- Created: 2024-01-01

BEGIN;

CREATE TYPE achievement_category AS ENUM (
    'streak', 'lesson', 'vocabulary', 'grammar', 'speaking',
    'listening', 'reading', 'writing', 'social', 'level',
    'consistency', 'speed', 'accuracy', 'milestone', 'special'
);

CREATE TYPE achievement_rarity AS ENUM ('common', 'uncommon', 'rare', 'epic', 'legendary');
CREATE TYPE achievement_trigger AS ENUM (
    'streak_days', 'lessons_completed', 'words_learned', 'xp_total',
    'accuracy_percent', 'perfect_lessons', 'days_active', 'level_reached',
    'assessments_passed', 'minutes_studied', 'exercises_correct',
    'words_mastered', 'login_streak', 'referrals', 'special_event'
);

CREATE TABLE IF NOT EXISTS achievements (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                VARCHAR(100) NOT NULL UNIQUE,
    slug                VARCHAR(100) NOT NULL UNIQUE,
    title               VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    long_description    TEXT,
    category            achievement_category NOT NULL,
    rarity              achievement_rarity NOT NULL DEFAULT 'common',

    -- Visual
    icon_name           VARCHAR(100),
    icon_url            TEXT,
    badge_url           TEXT NOT NULL,
    badge_locked_url    TEXT,
    color_hex           VARCHAR(7) NOT NULL DEFAULT '#FFD700',
    animation_url       TEXT,

    -- Trigger condition
    trigger_type        achievement_trigger NOT NULL,
    trigger_value       INTEGER NOT NULL CHECK (trigger_value > 0),
    trigger_condition   JSONB DEFAULT '{}',
    -- Additional conditions: {"level_id": 3, "topic": "business", etc.}

    -- Rewards
    xp_reward           INTEGER NOT NULL DEFAULT 25 CHECK (xp_reward >= 0),
    gems_reward         INTEGER NOT NULL DEFAULT 10 CHECK (gems_reward >= 0),
    title_reward        VARCHAR(100),
    -- Special user title unlocked by earning this achievement

    -- Progress tracking
    is_progressive      BOOLEAN NOT NULL DEFAULT FALSE,
    -- Progressive achievements show progress (e.g., "10/30 lessons completed")
    progress_milestones INTEGER[] DEFAULT '{}',
    -- For progressive: [10, 25, 50, 100] - unlock at each milestone

    -- Settings
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    is_hidden           BOOLEAN NOT NULL DEFAULT FALSE,
    is_stackable        BOOLEAN NOT NULL DEFAULT FALSE,
    is_limited_time     BOOLEAN NOT NULL DEFAULT FALSE,
    available_from      TIMESTAMPTZ,
    available_until     TIMESTAMPTZ,
    max_earners         INTEGER,
    -- NULL = unlimited; set for limited edition achievements

    sort_order          INTEGER NOT NULL DEFAULT 0,
    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User achievements (junction table)
CREATE TABLE IF NOT EXISTS user_achievements (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id      UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,

    -- Status
    is_earned           BOOLEAN NOT NULL DEFAULT FALSE,
    earned_at           TIMESTAMPTZ,
    notified_at         TIMESTAMPTZ,
    is_featured         BOOLEAN NOT NULL DEFAULT FALSE,
    -- Users can feature up to 3 achievements on their profile

    -- Progress (for progressive achievements)
    current_progress    INTEGER NOT NULL DEFAULT 0,
    target_value        INTEGER NOT NULL DEFAULT 1,
    progress_percent    DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE WHEN target_value > 0 THEN LEAST(current_progress::decimal / target_value * 100, 100) ELSE 0 END
    ) STORED,
    milestone_reached   INTEGER NOT NULL DEFAULT 0,

    -- Rewards claimed
    xp_claimed          INTEGER NOT NULL DEFAULT 0,
    gems_claimed        INTEGER NOT NULL DEFAULT 0,
    rewards_claimed_at  TIMESTAMPTZ,

    -- Context of earning
    source_entity_type  VARCHAR(50),
    source_entity_id    UUID,
    -- e.g., "lesson" + lesson_id that triggered it

    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(user_id, achievement_id)
);

-- Leaderboard (weekly/monthly XP rankings)
CREATE TABLE IF NOT EXISTS leaderboard_snapshots (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    period_type     VARCHAR(20) NOT NULL CHECK (period_type IN ('daily', 'weekly', 'monthly', 'all_time')),
    period_start    DATE NOT NULL,
    period_end      DATE NOT NULL,
    xp_earned       INTEGER NOT NULL DEFAULT 0,
    rank            INTEGER,
    league          VARCHAR(20) DEFAULT 'bronze',
    extra_data      JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(user_id, period_type, period_start)
);

CREATE INDEX idx_achievements_category ON achievements(category);
CREATE INDEX idx_achievements_rarity ON achievements(rarity);
CREATE INDEX idx_achievements_trigger ON achievements(trigger_type);
CREATE INDEX idx_achievements_active ON achievements(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_achievements_slug ON achievements(slug);
CREATE INDEX idx_achievements_limited ON achievements(available_from, available_until) WHERE is_limited_time = TRUE;

CREATE INDEX idx_user_achievements_user ON user_achievements(user_id);
CREATE INDEX idx_user_achievements_achievement ON user_achievements(achievement_id);
CREATE INDEX idx_user_achievements_earned ON user_achievements(user_id, earned_at DESC) WHERE is_earned = TRUE;
CREATE INDEX idx_user_achievements_progress ON user_achievements(user_id, current_progress, target_value) WHERE is_earned = FALSE;
CREATE INDEX idx_user_achievements_featured ON user_achievements(user_id) WHERE is_featured = TRUE;
CREATE INDEX idx_user_achievements_unnotified ON user_achievements(user_id) WHERE is_earned = TRUE AND notified_at IS NULL;

CREATE INDEX idx_leaderboard_period ON leaderboard_snapshots(period_type, period_start, xp_earned DESC);
CREATE INDEX idx_leaderboard_user ON leaderboard_snapshots(user_id, period_type);
CREATE INDEX idx_leaderboard_rank ON leaderboard_snapshots(period_type, period_start, rank) WHERE rank IS NOT NULL;

CREATE TRIGGER trigger_achievements_updated_at
    BEFORE UPDATE ON achievements
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_user_achievements_updated_at
    BEFORE UPDATE ON user_achievements
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE achievements IS 'Achievement and badge definitions with trigger conditions and rewards';
COMMENT ON TABLE user_achievements IS 'Per-user achievement progress and earned status';
COMMENT ON COLUMN achievements.is_progressive IS 'If true, shows progress bar toward completion';
COMMENT ON COLUMN achievements.progress_milestones IS 'Intermediate milestone values that unlock partial rewards';
COMMENT ON COLUMN user_achievements.is_featured IS 'User can pin up to 3 achievements to their public profile';

COMMIT;
