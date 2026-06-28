-- Migration: 012_create_test_results.sql
-- Description: Comprehensive test results and quiz tracking
-- Created: 2024-01-01

BEGIN;

CREATE TYPE test_type AS ENUM (
    'vocabulary_quiz', 'grammar_quiz', 'comprehension_test',
    'pronunciation_test', 'spelling_test', 'sentence_construction',
    'translation_test', 'cloze_test', 'listening_test',
    'weekly_challenge', 'daily_challenge', 'milestone_test',
    'timed_challenge', 'word_recall', 'flashcard_session'
);

CREATE TYPE test_result_status AS ENUM ('in_progress', 'completed', 'abandoned', 'timeout');

CREATE TABLE IF NOT EXISTS tests (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title               VARCHAR(255) NOT NULL,
    slug                VARCHAR(255) UNIQUE NOT NULL,
    description         TEXT,
    test_type           test_type NOT NULL,
    level_id            INTEGER REFERENCES levels(id) ON DELETE SET NULL,
    lesson_id           UUID REFERENCES lessons(id) ON DELETE SET NULL,

    -- Configuration
    question_count      INTEGER NOT NULL DEFAULT 10 CHECK (question_count > 0),
    time_limit_seconds  INTEGER CHECK (time_limit_seconds > 0),
    pass_threshold      DECIMAL(5,2) NOT NULL DEFAULT 70.0,
    randomize           BOOLEAN NOT NULL DEFAULT TRUE,
    show_feedback       BOOLEAN NOT NULL DEFAULT TRUE,
    allow_hints         BOOLEAN NOT NULL DEFAULT FALSE,
    allow_skip          BOOLEAN NOT NULL DEFAULT FALSE,

    -- Exercise pool
    exercise_ids        UUID[] DEFAULT '{}',
    word_ids            UUID[] DEFAULT '{}',
    topics              TEXT[] DEFAULT '{}',
    difficulty          difficulty_level DEFAULT 'medium',
    difficulty_adaptive BOOLEAN NOT NULL DEFAULT FALSE,

    -- Rewards
    xp_on_pass          INTEGER NOT NULL DEFAULT 20,
    xp_on_complete      INTEGER NOT NULL DEFAULT 5,
    xp_on_perfect       INTEGER NOT NULL DEFAULT 50,
    gems_on_pass        INTEGER NOT NULL DEFAULT 2,

    -- Availability
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    is_daily            BOOLEAN NOT NULL DEFAULT FALSE,
    available_from      TIMESTAMPTZ,
    available_until     TIMESTAMPTZ,
    requires_premium    BOOLEAN NOT NULL DEFAULT FALSE,

    max_attempts_per_day INTEGER DEFAULT 3,
    total_completions   INTEGER NOT NULL DEFAULT 0,
    avg_score           DECIMAL(5,2),

    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS test_results (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    test_id             UUID NOT NULL REFERENCES tests(id) ON DELETE CASCADE,
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id           UUID REFERENCES lessons(id) ON DELETE SET NULL,
    level_id            INTEGER REFERENCES levels(id) ON DELETE SET NULL,

    status              test_result_status NOT NULL DEFAULT 'in_progress',
    attempt_number      INTEGER NOT NULL DEFAULT 1,

    -- Scores
    score               DECIMAL(6,2),
    max_score           DECIMAL(6,2) NOT NULL DEFAULT 100,
    percentage          DECIMAL(5,2),
    passed              BOOLEAN,
    perfect             BOOLEAN NOT NULL DEFAULT FALSE,

    -- Questions
    total_questions     INTEGER NOT NULL DEFAULT 0,
    answered_questions  INTEGER NOT NULL DEFAULT 0,
    correct_answers     INTEGER NOT NULL DEFAULT 0,
    incorrect_answers   INTEGER NOT NULL DEFAULT 0,
    skipped_answers     INTEGER NOT NULL DEFAULT 0,
    hints_used          INTEGER NOT NULL DEFAULT 0,

    -- Per-skill breakdown
    skill_scores        JSONB DEFAULT '{}',
    -- {"grammar": 85, "vocabulary": 90, "reading": 75, ...}

    -- Question-by-question detail
    question_results    JSONB DEFAULT '[]',
    -- [{
    --   "question_index": 1,
    --   "exercise_id": "...",
    --   "word_id": "...",
    --   "question": "...",
    --   "user_answer": ...,
    --   "correct_answer": ...,
    --   "is_correct": true,
    --   "time_taken_ms": 3200,
    --   "hint_used": false,
    --   "difficulty": "medium"
    -- }]

    -- Timing
    started_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at        TIMESTAMPTZ,
    time_taken_seconds  INTEGER,
    avg_time_per_question_ms INTEGER,
    fastest_answer_ms   INTEGER,
    slowest_answer_ms   INTEGER,

    -- Adaptive difficulty
    difficulty_history  JSONB DEFAULT '[]',
    final_difficulty    difficulty_level DEFAULT 'medium',

    -- Rewards earned
    xp_earned           INTEGER NOT NULL DEFAULT 0,
    gems_earned         INTEGER NOT NULL DEFAULT 0,
    achievement_ids     UUID[] DEFAULT '{}',

    -- Performance analysis
    weakest_topics      TEXT[] DEFAULT '{}',
    strongest_topics    TEXT[] DEFAULT '{}',
    recommended_practice TEXT[] DEFAULT '{}',
    ai_feedback         TEXT,

    ip_address          INET,
    device_type         VARCHAR(20),
    app_version         VARCHAR(20),

    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Vocabulary flashcard sessions (SRS-based)
CREATE TABLE IF NOT EXISTS flashcard_sessions (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_type        VARCHAR(50) NOT NULL DEFAULT 'review',
    -- 'new', 'review', 'mixed', 'weak_words', 'topic_focus'

    level_id            INTEGER REFERENCES levels(id) ON DELETE SET NULL,
    topic               VARCHAR(100),

    status              test_result_status NOT NULL DEFAULT 'in_progress',
    started_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at        TIMESTAMPTZ,
    time_taken_seconds  INTEGER NOT NULL DEFAULT 0,

    -- Cards
    total_cards         INTEGER NOT NULL DEFAULT 0,
    cards_reviewed      INTEGER NOT NULL DEFAULT 0,
    cards_again         INTEGER NOT NULL DEFAULT 0,
    -- "Again" = completely forgot
    cards_hard          INTEGER NOT NULL DEFAULT 0,
    cards_good          INTEGER NOT NULL DEFAULT 0,
    cards_easy          INTEGER NOT NULL DEFAULT 0,

    -- Word IDs reviewed in this session
    word_ids_reviewed   UUID[] DEFAULT '{}',
    word_results        JSONB DEFAULT '[]',
    -- [{word_id: "...", rating: "good", time_ms: 2000, was_new: false}]

    xp_earned           INTEGER NOT NULL DEFAULT 0,
    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Daily/weekly challenges
CREATE TABLE IF NOT EXISTS challenges (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title               VARCHAR(255) NOT NULL,
    description         TEXT,
    challenge_type      VARCHAR(50) NOT NULL DEFAULT 'daily',
    test_id             UUID REFERENCES tests(id) ON DELETE CASCADE,
    level_id            INTEGER REFERENCES levels(id) ON DELETE SET NULL,
    available_date      DATE NOT NULL,
    expires_at          TIMESTAMPTZ NOT NULL,
    xp_reward           INTEGER NOT NULL DEFAULT 30,
    gems_reward         INTEGER NOT NULL DEFAULT 5,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    participant_count   INTEGER NOT NULL DEFAULT 0,
    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tests_type ON tests(test_type);
CREATE INDEX idx_tests_level ON tests(level_id);
CREATE INDEX idx_tests_lesson ON tests(lesson_id);
CREATE INDEX idx_tests_active ON tests(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_tests_daily ON tests(is_daily, available_from, available_until) WHERE is_daily = TRUE;
CREATE INDEX idx_tests_slug ON tests(slug);

CREATE INDEX idx_test_results_test ON test_results(test_id);
CREATE INDEX idx_test_results_user ON test_results(user_id);
CREATE INDEX idx_test_results_status ON test_results(status);
CREATE INDEX idx_test_results_user_test ON test_results(user_id, test_id);
CREATE INDEX idx_test_results_completed ON test_results(completed_at DESC) WHERE completed_at IS NOT NULL;
CREATE INDEX idx_test_results_passed ON test_results(user_id, passed) WHERE passed IS NOT NULL;
CREATE INDEX idx_test_results_score ON test_results(test_id, percentage DESC) WHERE status = 'completed';

CREATE INDEX idx_flashcard_sessions_user ON flashcard_sessions(user_id);
CREATE INDEX idx_flashcard_sessions_type ON flashcard_sessions(session_type);
CREATE INDEX idx_flashcard_sessions_created ON flashcard_sessions(created_at DESC);

CREATE INDEX idx_challenges_date ON challenges(available_date, challenge_type);
CREATE INDEX idx_challenges_active ON challenges(is_active, expires_at) WHERE is_active = TRUE;

CREATE TRIGGER trigger_tests_updated_at
    BEFORE UPDATE ON tests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_test_results_updated_at
    BEFORE UPDATE ON test_results
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Update test stats on completion
CREATE OR REPLACE FUNCTION update_test_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        UPDATE tests
        SET
            total_completions = total_completions + 1,
            avg_score = (
                (COALESCE(avg_score, 0) * total_completions + COALESCE(NEW.percentage, 0))
                / (total_completions + 1)
            )
        WHERE id = NEW.test_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_test_stats
    AFTER UPDATE ON test_results
    FOR EACH ROW
    EXECUTE FUNCTION update_test_stats();

COMMENT ON TABLE tests IS 'Test and quiz definitions with configuration for various assessment types';
COMMENT ON TABLE test_results IS 'Detailed results for each user test attempt with per-question breakdown';
COMMENT ON TABLE flashcard_sessions IS 'Spaced repetition flashcard review sessions';
COMMENT ON TABLE challenges IS 'Daily and weekly time-limited challenges';

COMMIT;
