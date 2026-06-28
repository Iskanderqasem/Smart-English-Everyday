-- Migration: 009_create_sessions.sql
-- Description: Reading, Writing, and Speaking practice session tables
-- Created: 2024-01-01

BEGIN;

CREATE TYPE session_status AS ENUM ('active', 'paused', 'completed', 'abandoned', 'expired');

-- Reading sessions
CREATE TABLE IF NOT EXISTS reading_sessions (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id           UUID REFERENCES lessons(id) ON DELETE SET NULL,
    level_id            INTEGER REFERENCES levels(id) ON DELETE SET NULL,

    -- Content
    passage_title       VARCHAR(255),
    passage_text        TEXT NOT NULL,
    passage_source      VARCHAR(255),
    passage_url         TEXT,
    word_count          INTEGER,
    reading_level       cefr_level,
    topic               VARCHAR(100),
    genre               VARCHAR(50),

    -- Performance
    status              session_status NOT NULL DEFAULT 'active',
    started_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at        TIMESTAMPTZ,
    time_spent_seconds  INTEGER NOT NULL DEFAULT 0,
    words_per_minute    DECIMAL(6,2),
    scroll_percent      DECIMAL(5,2) DEFAULT 0,
    completed_reading   BOOLEAN NOT NULL DEFAULT FALSE,

    -- Comprehension questions
    questions_answered  INTEGER NOT NULL DEFAULT 0,
    questions_correct   INTEGER NOT NULL DEFAULT 0,
    comprehension_score DECIMAL(5,2),

    -- Vocabulary in passage
    unknown_words       TEXT[] DEFAULT '{}',
    looked_up_words     TEXT[] DEFAULT '{}',
    saved_words         TEXT[] DEFAULT '{}',

    xp_earned           INTEGER NOT NULL DEFAULT 0,
    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Writing sessions
CREATE TABLE IF NOT EXISTS writing_sessions (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id           UUID REFERENCES lessons(id) ON DELETE SET NULL,
    level_id            INTEGER REFERENCES levels(id) ON DELETE SET NULL,

    -- Prompt
    prompt_title        VARCHAR(255),
    prompt_text         TEXT,
    prompt_type         VARCHAR(50),
    -- essay, email, story, description, argument, summary, etc.
    target_word_count   INTEGER,
    target_audience     VARCHAR(100),

    -- User's writing
    status              session_status NOT NULL DEFAULT 'active',
    draft_text          TEXT,
    final_text          TEXT,
    word_count          INTEGER NOT NULL DEFAULT 0,
    character_count     INTEGER NOT NULL DEFAULT 0,
    revision_count      INTEGER NOT NULL DEFAULT 0,

    -- Timing
    started_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at        TIMESTAMPTZ,
    submitted_at        TIMESTAMPTZ,
    time_spent_seconds  INTEGER NOT NULL DEFAULT 0,

    -- AI feedback
    ai_feedback         JSONB DEFAULT '{}',
    -- Structure: {
    --   "overall_score": 85,
    --   "grammar_score": 90,
    --   "vocabulary_score": 80,
    --   "coherence_score": 85,
    --   "grammar_errors": [...],
    --   "vocabulary_suggestions": [...],
    --   "strengths": [...],
    --   "improvements": [...]
    -- }
    grammar_errors      JSONB DEFAULT '[]',
    vocabulary_suggestions JSONB DEFAULT '[]',
    overall_score       DECIMAL(5,2),
    grammar_score       DECIMAL(5,2),
    vocabulary_score    DECIMAL(5,2),
    coherence_score     DECIMAL(5,2),
    ai_model_used       VARCHAR(50),
    feedback_generated_at TIMESTAMPTZ,

    -- Teacher review (optional)
    teacher_review      TEXT,
    teacher_score       DECIMAL(5,2),
    teacher_id          UUID REFERENCES users(id) ON DELETE SET NULL,
    teacher_reviewed_at TIMESTAMPTZ,

    xp_earned           INTEGER NOT NULL DEFAULT 0,
    is_public           BOOLEAN NOT NULL DEFAULT FALSE,
    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Speaking sessions
CREATE TABLE IF NOT EXISTS speaking_sessions (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id           UUID REFERENCES lessons(id) ON DELETE SET NULL,
    level_id            INTEGER REFERENCES levels(id) ON DELETE SET NULL,

    -- Prompt
    prompt_text         TEXT NOT NULL,
    prompt_audio_url    TEXT,
    prompt_type         VARCHAR(50),
    -- pronunciation, conversation, monologue, reading_aloud, debate, etc.
    target_text         TEXT,
    -- For pronunciation/reading: the text to speak

    -- Recording
    status              session_status NOT NULL DEFAULT 'active',
    audio_url           TEXT,
    audio_duration_secs DECIMAL(8,2),
    audio_size_bytes    INTEGER,
    transcript          TEXT,
    transcript_confidence DECIMAL(5,2),

    -- Timing
    started_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at        TIMESTAMPTZ,
    time_spent_seconds  INTEGER NOT NULL DEFAULT 0,

    -- AI assessment
    ai_assessment       JSONB DEFAULT '{}',
    -- Structure: {
    --   "overall_score": 80,
    --   "pronunciation_score": 85,
    --   "fluency_score": 75,
    --   "vocabulary_score": 80,
    --   "grammar_score": 80,
    --   "phoneme_analysis": {...},
    --   "word_scores": [...],
    --   "feedback": "..."
    -- }
    pronunciation_score DECIMAL(5,2),
    fluency_score       DECIMAL(5,2),
    overall_score       DECIMAL(5,2),
    ai_feedback         TEXT,
    ai_model_used       VARCHAR(50),
    feedback_generated_at TIMESTAMPTZ,

    -- Word-level analysis
    word_scores         JSONB DEFAULT '[]',
    mispronounced_words TEXT[] DEFAULT '{}',
    filler_words        TEXT[] DEFAULT '{}',
    speech_rate_wpm     DECIMAL(6,2),
    pause_count         INTEGER,
    avg_pause_ms        DECIMAL(8,2),

    xp_earned           INTEGER NOT NULL DEFAULT 0,
    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Listening sessions
CREATE TABLE IF NOT EXISTS listening_sessions (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id           UUID REFERENCES lessons(id) ON DELETE SET NULL,
    level_id            INTEGER REFERENCES levels(id) ON DELETE SET NULL,

    audio_title         VARCHAR(255),
    audio_url           TEXT NOT NULL,
    audio_duration_secs INTEGER,
    transcript          TEXT,
    audio_cefr_level    cefr_level,
    topic               VARCHAR(100),
    accent              VARCHAR(50),
    -- british, american, australian, etc.

    status              session_status NOT NULL DEFAULT 'active',
    started_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at        TIMESTAMPTZ,
    time_spent_seconds  INTEGER NOT NULL DEFAULT 0,
    playback_position_secs INTEGER DEFAULT 0,
    playback_count      INTEGER NOT NULL DEFAULT 0,
    completed_listening BOOLEAN NOT NULL DEFAULT FALSE,

    questions_answered  INTEGER NOT NULL DEFAULT 0,
    questions_correct   INTEGER NOT NULL DEFAULT 0,
    comprehension_score DECIMAL(5,2),

    unknown_words       TEXT[] DEFAULT '{}',
    saved_words         TEXT[] DEFAULT '{}',

    xp_earned           INTEGER NOT NULL DEFAULT 0,
    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User device auth sessions (not learning sessions)
CREATE TABLE IF NOT EXISTS auth_sessions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash      VARCHAR(255) NOT NULL UNIQUE,
    refresh_token_hash VARCHAR(255) UNIQUE,
    token_family    UUID NOT NULL,
    device_name     VARCHAR(100),
    device_type     VARCHAR(20),
    device_os       VARCHAR(50),
    app_version     VARCHAR(20),
    ip_address      INET,
    user_agent      TEXT,
    location        JSONB DEFAULT '{}',
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    last_active_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMPTZ NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reading_sessions_user ON reading_sessions(user_id);
CREATE INDEX idx_reading_sessions_lesson ON reading_sessions(lesson_id);
CREATE INDEX idx_reading_sessions_created ON reading_sessions(created_at DESC);
CREATE INDEX idx_reading_sessions_status ON reading_sessions(status);

CREATE INDEX idx_writing_sessions_user ON writing_sessions(user_id);
CREATE INDEX idx_writing_sessions_lesson ON writing_sessions(lesson_id);
CREATE INDEX idx_writing_sessions_status ON writing_sessions(status);
CREATE INDEX idx_writing_sessions_created ON writing_sessions(created_at DESC);

CREATE INDEX idx_speaking_sessions_user ON speaking_sessions(user_id);
CREATE INDEX idx_speaking_sessions_lesson ON speaking_sessions(lesson_id);
CREATE INDEX idx_speaking_sessions_status ON speaking_sessions(status);
CREATE INDEX idx_speaking_sessions_created ON speaking_sessions(created_at DESC);

CREATE INDEX idx_listening_sessions_user ON listening_sessions(user_id);
CREATE INDEX idx_listening_sessions_lesson ON listening_sessions(lesson_id);
CREATE INDEX idx_listening_sessions_status ON listening_sessions(status);

CREATE INDEX idx_auth_sessions_user ON auth_sessions(user_id);
CREATE INDEX idx_auth_sessions_token ON auth_sessions(token_hash);
CREATE INDEX idx_auth_sessions_refresh ON auth_sessions(refresh_token_hash) WHERE refresh_token_hash IS NOT NULL;
CREATE INDEX idx_auth_sessions_active ON auth_sessions(user_id) WHERE is_active = TRUE;
CREATE INDEX idx_auth_sessions_expires ON auth_sessions(expires_at) WHERE is_active = TRUE;
CREATE INDEX idx_auth_sessions_family ON auth_sessions(token_family);

CREATE TRIGGER trigger_writing_sessions_updated_at
    BEFORE UPDATE ON writing_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_speaking_sessions_updated_at
    BEFORE UPDATE ON speaking_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE reading_sessions IS 'Tracks user reading practice sessions including comprehension scores';
COMMENT ON TABLE writing_sessions IS 'Writing practice sessions with AI feedback and scoring';
COMMENT ON TABLE speaking_sessions IS 'Speaking and pronunciation sessions with audio recording and AI analysis';
COMMENT ON TABLE listening_sessions IS 'Listening comprehension sessions';
COMMENT ON TABLE auth_sessions IS 'JWT authentication sessions for device management and token rotation';

COMMIT;
