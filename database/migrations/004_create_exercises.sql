-- Migration: 004_create_exercises.sql
-- Description: Create exercises table for lesson interactive activities
-- Created: 2024-01-01

BEGIN;

CREATE TYPE exercise_type AS ENUM (
    'multiple_choice',
    'fill_in_blank',
    'true_false',
    'matching',
    'ordering',
    'drag_drop',
    'type_answer',
    'select_all',
    'audio_record',
    'pronunciation',
    'image_select',
    'sentence_build',
    'translation',
    'error_correction',
    'cloze_test',
    'word_scramble',
    'dialogue_completion',
    'reading_comprehension',
    'listening_comprehension',
    'open_ended'
);

CREATE TYPE exercise_status AS ENUM ('draft', 'active', 'archived');

CREATE TABLE IF NOT EXISTS exercises (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id           UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    level_id            INTEGER NOT NULL REFERENCES levels(id) ON DELETE RESTRICT,

    -- Identity
    title               VARCHAR(255),
    instructions        TEXT NOT NULL,
    instructions_audio_url TEXT,
    exercise_type       exercise_type NOT NULL,
    status              exercise_status NOT NULL DEFAULT 'active',

    -- Content
    question            TEXT NOT NULL,
    question_audio_url  TEXT,
    question_image_url  TEXT,
    question_html       TEXT,
    context             TEXT,
    context_audio_url   TEXT,
    hint                TEXT,
    explanation         TEXT,

    -- Answer configuration
    correct_answer      JSONB NOT NULL,
    accepted_answers    JSONB DEFAULT '[]',
    options             JSONB DEFAULT '[]',
    answer_audio_url    TEXT,
    answer_image_url    TEXT,
    is_case_sensitive   BOOLEAN NOT NULL DEFAULT FALSE,
    allow_partial_credit BOOLEAN NOT NULL DEFAULT FALSE,
    max_partial_score   DECIMAL(5,2) DEFAULT 100.00,

    -- Matching / ordering specific
    pairs               JSONB DEFAULT '[]',
    items_to_order      JSONB DEFAULT '[]',

    -- Timing
    time_limit_seconds  INTEGER CHECK (time_limit_seconds > 0),
    recommended_seconds INTEGER,

    -- Scoring
    points              INTEGER NOT NULL DEFAULT 10 CHECK (points > 0),
    xp_reward           INTEGER NOT NULL DEFAULT 5 CHECK (xp_reward >= 0),
    difficulty          difficulty_level NOT NULL DEFAULT 'medium',

    -- Ordering
    sort_order          INTEGER NOT NULL DEFAULT 0,
    is_required         BOOLEAN NOT NULL DEFAULT TRUE,
    is_timed            BOOLEAN NOT NULL DEFAULT FALSE,
    skip_allowed        BOOLEAN NOT NULL DEFAULT FALSE,

    -- Media
    audio_url           TEXT,
    video_url           TEXT,
    image_url           TEXT,
    animation_url       TEXT,

    -- Skill assessment
    skill_assessed      skill_type,
    grammar_point       VARCHAR(100),
    vocabulary_word_id  UUID REFERENCES words(id) ON DELETE SET NULL,
    topic               VARCHAR(100),
    tags                TEXT[] DEFAULT '{}',

    -- AI generation
    ai_generated        BOOLEAN NOT NULL DEFAULT FALSE,
    ai_model_version    VARCHAR(50),

    -- Stats
    total_attempts      INTEGER NOT NULL DEFAULT 0,
    total_correct       INTEGER NOT NULL DEFAULT 0,
    avg_time_seconds    DECIMAL(8,2),
    skip_count          INTEGER NOT NULL DEFAULT 0,

    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Exercise attempts (user responses)
CREATE TABLE IF NOT EXISTS exercise_attempts (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    exercise_id         UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_progress_id  UUID,

    user_answer         JSONB NOT NULL,
    is_correct          BOOLEAN NOT NULL,
    is_partial_correct  BOOLEAN NOT NULL DEFAULT FALSE,
    score               DECIMAL(5,2) NOT NULL DEFAULT 0,
    max_score           DECIMAL(5,2) NOT NULL DEFAULT 100,
    time_taken_seconds  INTEGER,
    hint_used           BOOLEAN NOT NULL DEFAULT FALSE,
    skip_used           BOOLEAN NOT NULL DEFAULT FALSE,
    xp_earned           INTEGER NOT NULL DEFAULT 0,
    attempt_number      INTEGER NOT NULL DEFAULT 1,

    device_type         VARCHAR(20),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_exercises_lesson ON exercises(lesson_id);
CREATE INDEX idx_exercises_level ON exercises(level_id);
CREATE INDEX idx_exercises_type ON exercises(exercise_type);
CREATE INDEX idx_exercises_status ON exercises(status);
CREATE INDEX idx_exercises_sort ON exercises(lesson_id, sort_order);
CREATE INDEX idx_exercises_difficulty ON exercises(difficulty);
CREATE INDEX idx_exercises_skill ON exercises(skill_assessed) WHERE skill_assessed IS NOT NULL;
CREATE INDEX idx_exercises_word ON exercises(vocabulary_word_id) WHERE vocabulary_word_id IS NOT NULL;
CREATE INDEX idx_exercises_tags ON exercises USING gin(tags);

CREATE INDEX idx_exercise_attempts_exercise ON exercise_attempts(exercise_id);
CREATE INDEX idx_exercise_attempts_user ON exercise_attempts(user_id);
CREATE INDEX idx_exercise_attempts_user_exercise ON exercise_attempts(user_id, exercise_id);
CREATE INDEX idx_exercise_attempts_correct ON exercise_attempts(is_correct);
CREATE INDEX idx_exercise_attempts_created ON exercise_attempts(created_at DESC);

CREATE TRIGGER trigger_exercises_updated_at
    BEFORE UPDATE ON exercises
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Update exercise stats on new attempt
CREATE OR REPLACE FUNCTION update_exercise_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE exercises
    SET
        total_attempts = total_attempts + 1,
        total_correct = total_correct + CASE WHEN NEW.is_correct THEN 1 ELSE 0 END,
        avg_time_seconds = (
            (avg_time_seconds * total_attempts + COALESCE(NEW.time_taken_seconds, avg_time_seconds, 0))
            / (total_attempts + 1)
        )
    WHERE id = NEW.exercise_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_exercise_stats
    AFTER INSERT ON exercise_attempts
    FOR EACH ROW
    EXECUTE FUNCTION update_exercise_stats();

COMMENT ON TABLE exercises IS 'Interactive exercises within lessons, supporting many types of activities';
COMMENT ON TABLE exercise_attempts IS 'Records each user attempt at an exercise with their answer and score';

COMMIT;
