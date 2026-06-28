-- Migration: 007_create_assessments.sql
-- Description: Assessment results table for placement tests and level evaluations
-- Created: 2024-01-01

BEGIN;

CREATE TYPE assessment_type AS ENUM (
    'placement', 'level_completion', 'unit_review',
    'diagnostic', 'practice', 'mock_exam', 'final_exam', 'ielts_prep', 'toefl_prep'
);

CREATE TYPE assessment_status AS ENUM ('not_started', 'in_progress', 'completed', 'abandoned', 'expired');

CREATE TABLE IF NOT EXISTS assessments (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title               VARCHAR(255) NOT NULL,
    slug                VARCHAR(255) UNIQUE NOT NULL,
    description         TEXT,
    assessment_type     assessment_type NOT NULL DEFAULT 'practice',
    level_id            INTEGER REFERENCES levels(id) ON DELETE SET NULL,

    -- Structure
    total_questions     INTEGER NOT NULL CHECK (total_questions > 0),
    total_points        INTEGER NOT NULL DEFAULT 100,
    pass_score          DECIMAL(5,2) NOT NULL DEFAULT 70.0,
    time_limit_minutes  INTEGER CHECK (time_limit_minutes > 0),

    -- Content (question IDs from exercises table)
    exercise_ids        UUID[] DEFAULT '{}',
    sections            JSONB DEFAULT '[]',
    -- Structure: [{"name": "...", "type": "...", "exercise_ids": [...], "time_limit": null}]

    -- Skills weighting
    skills_weighting    JSONB DEFAULT '{}',
    -- Structure: {"reading": 25, "writing": 25, "listening": 25, "speaking": 25}

    -- Settings
    randomize_questions BOOLEAN NOT NULL DEFAULT FALSE,
    randomize_options   BOOLEAN NOT NULL DEFAULT FALSE,
    show_answers_after  BOOLEAN NOT NULL DEFAULT TRUE,
    allow_retake        BOOLEAN NOT NULL DEFAULT TRUE,
    retake_cooldown_hours INTEGER DEFAULT 24,
    max_attempts        INTEGER DEFAULT 3,

    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    is_featured         BOOLEAN NOT NULL DEFAULT FALSE,
    requires_premium    BOOLEAN NOT NULL DEFAULT FALSE,
    thumbnail_url       TEXT,

    xp_reward_pass      INTEGER NOT NULL DEFAULT 50,
    xp_reward_perfect   INTEGER NOT NULL DEFAULT 100,
    gems_reward_pass    INTEGER NOT NULL DEFAULT 5,

    created_by          UUID REFERENCES users(id) ON DELETE SET NULL,
    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS assessment_results (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assessment_id       UUID NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    status              assessment_status NOT NULL DEFAULT 'not_started',
    attempt_number      INTEGER NOT NULL DEFAULT 1,

    -- Scores
    total_score         DECIMAL(6,2),
    max_score           DECIMAL(6,2) NOT NULL DEFAULT 100,
    percentage          DECIMAL(5,2),
    passed              BOOLEAN,

    -- Per-skill scores
    reading_score       DECIMAL(5,2),
    writing_score       DECIMAL(5,2),
    listening_score     DECIMAL(5,2),
    speaking_score      DECIMAL(5,2),
    vocabulary_score    DECIMAL(5,2),
    grammar_score       DECIMAL(5,2),

    -- CEFR assessment result (for placement tests)
    assessed_cefr_level cefr_level,
    recommended_level_id INTEGER REFERENCES levels(id) ON DELETE SET NULL,
    recommended_path    TEXT,

    -- Timing
    started_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at        TIMESTAMPTZ,
    time_taken_seconds  INTEGER,
    time_limit_seconds  INTEGER,

    -- Answers
    answers             JSONB DEFAULT '[]',
    -- Structure: [{"exercise_id": "...", "user_answer": ..., "correct_answer": ..., "is_correct": bool, "score": num, "time_taken": num}]
    question_order      UUID[] DEFAULT '{}',

    -- Results analysis
    strengths           TEXT[] DEFAULT '{}',
    weaknesses          TEXT[] DEFAULT '{}',
    recommendations     JSONB DEFAULT '[]',
    feedback            TEXT,
    detailed_feedback   JSONB DEFAULT '{}',

    -- Rewards
    xp_earned           INTEGER NOT NULL DEFAULT 0,
    gems_earned         INTEGER NOT NULL DEFAULT 0,
    certificate_url     TEXT,
    certificate_issued_at TIMESTAMPTZ,

    ip_address          INET,
    user_agent          TEXT,
    device_type         VARCHAR(20),

    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_assessments_type ON assessments(assessment_type);
CREATE INDEX idx_assessments_level ON assessments(level_id);
CREATE INDEX idx_assessments_active ON assessments(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_assessments_slug ON assessments(slug);

CREATE INDEX idx_assessment_results_assessment ON assessment_results(assessment_id);
CREATE INDEX idx_assessment_results_user ON assessment_results(user_id);
CREATE INDEX idx_assessment_results_status ON assessment_results(status);
CREATE INDEX idx_assessment_results_user_assessment ON assessment_results(user_id, assessment_id);
CREATE INDEX idx_assessment_results_completed ON assessment_results(completed_at DESC) WHERE completed_at IS NOT NULL;
CREATE INDEX idx_assessment_results_passed ON assessment_results(user_id, passed) WHERE passed IS NOT NULL;
CREATE INDEX idx_assessment_results_cefr ON assessment_results(assessed_cefr_level) WHERE assessed_cefr_level IS NOT NULL;

CREATE TRIGGER trigger_assessments_updated_at
    BEFORE UPDATE ON assessments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_assessment_results_updated_at
    BEFORE UPDATE ON assessment_results
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE assessments IS 'Assessment templates including placement tests, level exams, and practice tests';
COMMENT ON TABLE assessment_results IS 'Individual user results for each assessment attempt';
COMMENT ON COLUMN assessment_results.assessed_cefr_level IS 'For placement tests: the CEFR level determined by the assessment';

COMMIT;
