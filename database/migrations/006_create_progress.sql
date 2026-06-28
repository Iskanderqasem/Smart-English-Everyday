-- Migration: 006_create_progress.sql
-- Description: User progress tracking tables
-- Created: 2024-01-01

BEGIN;

CREATE TYPE progress_status AS ENUM ('not_started', 'in_progress', 'completed', 'mastered', 'skipped', 'locked');
CREATE TYPE completion_type AS ENUM ('first_time', 'review', 'perfect', 'retry');

-- Daily activity log
CREATE TABLE IF NOT EXISTS daily_activities (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_date   DATE NOT NULL,

    -- Minutes
    minutes_studied     INTEGER NOT NULL DEFAULT 0 CHECK (minutes_studied >= 0),
    goal_minutes        INTEGER NOT NULL DEFAULT 15,
    goal_achieved       BOOLEAN NOT NULL DEFAULT FALSE,

    -- Counts
    lessons_completed   INTEGER NOT NULL DEFAULT 0,
    exercises_done      INTEGER NOT NULL DEFAULT 0,
    words_reviewed      INTEGER NOT NULL DEFAULT 0,
    words_learned_new   INTEGER NOT NULL DEFAULT 0,
    xp_earned           INTEGER NOT NULL DEFAULT 0,

    -- Accuracy
    correct_answers     INTEGER NOT NULL DEFAULT 0,
    total_answers       INTEGER NOT NULL DEFAULT 0,
    accuracy_percent    DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE WHEN total_answers > 0 THEN (correct_answers::decimal / total_answers * 100) ELSE 0 END
    ) STORED,

    -- Streak
    streak_day          INTEGER NOT NULL DEFAULT 0,
    is_streak_day       BOOLEAN NOT NULL DEFAULT FALSE,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(user_id, activity_date)
);

-- Lesson progress
CREATE TABLE IF NOT EXISTS lesson_progress (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id           UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    level_id            INTEGER NOT NULL REFERENCES levels(id) ON DELETE RESTRICT,

    status              progress_status NOT NULL DEFAULT 'not_started',
    completion_type     completion_type,

    -- Scores
    score               DECIMAL(5,2),
    accuracy_percent    DECIMAL(5,2),
    max_score           DECIMAL(5,2) NOT NULL DEFAULT 100,
    best_score          DECIMAL(5,2),

    -- Attempts
    attempt_count       INTEGER NOT NULL DEFAULT 0,
    first_attempt_score DECIMAL(5,2),

    -- Timing
    time_spent_seconds  INTEGER NOT NULL DEFAULT 0,
    started_at          TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,
    last_activity_at    TIMESTAMPTZ,

    -- Progress within lesson
    current_exercise_index INTEGER NOT NULL DEFAULT 0,
    exercises_completed    INTEGER NOT NULL DEFAULT 0,
    total_exercises        INTEGER NOT NULL DEFAULT 0,
    exercises_correct      INTEGER NOT NULL DEFAULT 0,
    checkpoints            JSONB DEFAULT '{}',

    -- Rewards earned
    xp_earned           INTEGER NOT NULL DEFAULT 0,
    gems_earned         INTEGER NOT NULL DEFAULT 0,
    perfect_lesson      BOOLEAN NOT NULL DEFAULT FALSE,
    hearts_lost         INTEGER NOT NULL DEFAULT 0,

    -- Review
    is_review           BOOLEAN NOT NULL DEFAULT FALSE,
    next_review_at      TIMESTAMPTZ,
    review_count        INTEGER NOT NULL DEFAULT 0,

    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(user_id, lesson_id)
);

-- Level progress
CREATE TABLE IF NOT EXISTS level_progress (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    level_id            INTEGER NOT NULL REFERENCES levels(id) ON DELETE RESTRICT,

    status              progress_status NOT NULL DEFAULT 'locked',
    unlocked_at         TIMESTAMPTZ,
    started_at          TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,

    -- Stats
    lessons_completed   INTEGER NOT NULL DEFAULT 0,
    lessons_total       INTEGER NOT NULL DEFAULT 0,
    words_learned       INTEGER NOT NULL DEFAULT 0,
    total_xp_earned     INTEGER NOT NULL DEFAULT 0,
    avg_accuracy        DECIMAL(5,2),
    time_spent_minutes  INTEGER NOT NULL DEFAULT 0,
    completion_percent  DECIMAL(5,2) NOT NULL DEFAULT 0,

    -- Assessment
    placement_score     DECIMAL(5,2),
    final_score         DECIMAL(5,2),
    passed              BOOLEAN,
    passed_at           TIMESTAMPTZ,
    certificate_url     TEXT,

    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(user_id, level_id)
);

-- XP transaction log
CREATE TABLE IF NOT EXISTS xp_transactions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount          INTEGER NOT NULL,
    balance_after   INTEGER NOT NULL,
    source_type     VARCHAR(50) NOT NULL,
    source_id       UUID,
    description     TEXT,
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_daily_activities_user ON daily_activities(user_id);
CREATE INDEX idx_daily_activities_date ON daily_activities(activity_date DESC);
CREATE INDEX idx_daily_activities_user_date ON daily_activities(user_id, activity_date DESC);
CREATE INDEX idx_daily_activities_streak ON daily_activities(user_id, is_streak_day) WHERE is_streak_day = TRUE;

CREATE INDEX idx_lesson_progress_user ON lesson_progress(user_id);
CREATE INDEX idx_lesson_progress_lesson ON lesson_progress(lesson_id);
CREATE INDEX idx_lesson_progress_level ON lesson_progress(level_id);
CREATE INDEX idx_lesson_progress_status ON lesson_progress(status);
CREATE INDEX idx_lesson_progress_user_level ON lesson_progress(user_id, level_id);
CREATE INDEX idx_lesson_progress_completed ON lesson_progress(user_id, completed_at DESC) WHERE completed_at IS NOT NULL;
CREATE INDEX idx_lesson_progress_review ON lesson_progress(user_id, next_review_at) WHERE is_review = TRUE;

CREATE INDEX idx_level_progress_user ON level_progress(user_id);
CREATE INDEX idx_level_progress_level ON level_progress(level_id);
CREATE INDEX idx_level_progress_status ON level_progress(user_id, status);

CREATE INDEX idx_xp_transactions_user ON xp_transactions(user_id);
CREATE INDEX idx_xp_transactions_created ON xp_transactions(created_at DESC);
CREATE INDEX idx_xp_transactions_source ON xp_transactions(source_type, source_id);

CREATE TRIGGER trigger_daily_activities_updated_at
    BEFORE UPDATE ON daily_activities
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_lesson_progress_updated_at
    BEFORE UPDATE ON lesson_progress
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_level_progress_updated_at
    BEFORE UPDATE ON level_progress
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Update user stats when lesson is completed
CREATE OR REPLACE FUNCTION handle_lesson_completion()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        UPDATE users
        SET
            total_lessons_completed = total_lessons_completed + 1,
            total_xp = total_xp + NEW.xp_earned,
            total_minutes_studied = total_minutes_studied + COALESCE(NEW.time_spent_seconds / 60, 0)
        WHERE id = NEW.user_id;

        -- Log XP transaction
        INSERT INTO xp_transactions (user_id, amount, balance_after, source_type, source_id, description)
        SELECT
            NEW.user_id,
            NEW.xp_earned,
            u.total_xp,
            'lesson',
            NEW.lesson_id,
            'Lesson completed: ' || l.title
        FROM users u
        JOIN lessons l ON l.id = NEW.lesson_id
        WHERE u.id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_lesson_completion
    AFTER UPDATE ON lesson_progress
    FOR EACH ROW
    EXECUTE FUNCTION handle_lesson_completion();

COMMENT ON TABLE daily_activities IS 'Daily learning activity summary per user for streak tracking and statistics';
COMMENT ON TABLE lesson_progress IS 'Tracks each user''s progress on each lesson including scores and completion status';
COMMENT ON TABLE level_progress IS 'Tracks overall level advancement and certification per user';
COMMENT ON TABLE xp_transactions IS 'Immutable log of all XP earned/spent for auditing and analytics';

COMMIT;
