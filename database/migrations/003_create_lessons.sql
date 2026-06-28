-- Migration: 003_create_lessons.sql
-- Description: Create lessons table with foreign keys to levels
-- Created: 2024-01-01

BEGIN;

CREATE TYPE lesson_type AS ENUM (
    'vocabulary', 'grammar', 'reading', 'writing',
    'speaking', 'listening', 'conversation', 'pronunciation',
    'culture', 'review', 'assessment'
);

CREATE TYPE lesson_status AS ENUM ('draft', 'review', 'published', 'archived', 'deprecated');
CREATE TYPE difficulty_level AS ENUM ('very_easy', 'easy', 'medium', 'hard', 'very_hard');
CREATE TYPE skill_type AS ENUM ('reading', 'writing', 'speaking', 'listening', 'vocabulary', 'grammar');

CREATE TABLE IF NOT EXISTS lessons (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level_id            INTEGER NOT NULL REFERENCES levels(id) ON DELETE RESTRICT,
    title               VARCHAR(255) NOT NULL,
    slug                VARCHAR(255) NOT NULL UNIQUE,
    description         TEXT,
    short_description   VARCHAR(500),
    lesson_type         lesson_type NOT NULL DEFAULT 'vocabulary',
    difficulty          difficulty_level NOT NULL DEFAULT 'medium',
    status              lesson_status NOT NULL DEFAULT 'draft',

    -- Ordering
    lesson_number       INTEGER NOT NULL,
    unit_number         INTEGER NOT NULL DEFAULT 1,
    sort_order          INTEGER NOT NULL DEFAULT 0,

    -- Content
    content             JSONB NOT NULL DEFAULT '{}',
    content_url         TEXT,
    transcript          TEXT,
    summary             TEXT,
    key_points          TEXT[] DEFAULT '{}',
    grammar_notes       TEXT,
    cultural_notes      TEXT,

    -- Media
    thumbnail_url       TEXT,
    banner_url          TEXT,
    audio_url           TEXT,
    video_url           TEXT,
    video_duration_secs INTEGER,

    -- Skills
    primary_skill       skill_type NOT NULL DEFAULT 'vocabulary',
    secondary_skills    skill_type[] DEFAULT '{}',
    topics              TEXT[] DEFAULT '{}',
    tags                TEXT[] DEFAULT '{}',
    vocabulary_words    UUID[] DEFAULT '{}',

    -- Timing
    estimated_minutes   INTEGER NOT NULL DEFAULT 10 CHECK (estimated_minutes > 0),
    min_minutes         INTEGER,
    max_minutes         INTEGER,

    -- Prerequisites
    prerequisite_lesson_ids UUID[] DEFAULT '{}',
    prerequisite_level_id   INTEGER REFERENCES levels(id) ON DELETE SET NULL,

    -- Gamification
    xp_reward           INTEGER NOT NULL DEFAULT 10 CHECK (xp_reward >= 0),
    gems_reward         INTEGER NOT NULL DEFAULT 0 CHECK (gems_reward >= 0),
    bonus_xp_perfect    INTEGER NOT NULL DEFAULT 5,
    hearts_cost         INTEGER NOT NULL DEFAULT 0,

    -- Stats (denormalized for performance)
    total_completions   INTEGER NOT NULL DEFAULT 0,
    total_attempts      INTEGER NOT NULL DEFAULT 0,
    avg_score           DECIMAL(5,2),
    avg_completion_mins DECIMAL(6,2),
    like_count          INTEGER NOT NULL DEFAULT 0,
    bookmark_count      INTEGER NOT NULL DEFAULT 0,

    -- AI generation
    ai_generated        BOOLEAN NOT NULL DEFAULT FALSE,
    ai_model_version    VARCHAR(50),
    ai_prompt_used      TEXT,

    -- SEO
    meta_title          VARCHAR(60),
    meta_description    VARCHAR(160),
    meta_keywords       TEXT[],

    -- Author
    created_by          UUID REFERENCES users(id) ON DELETE SET NULL,
    reviewed_by         UUID REFERENCES users(id) ON DELETE SET NULL,
    published_at        TIMESTAMPTZ,
    archived_at         TIMESTAMPTZ,

    is_free             BOOLEAN NOT NULL DEFAULT FALSE,
    is_featured         BOOLEAN NOT NULL DEFAULT FALSE,
    requires_premium    BOOLEAN NOT NULL DEFAULT FALSE,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(level_id, lesson_number),
    CONSTRAINT valid_duration CHECK (
        min_minutes IS NULL OR max_minutes IS NULL OR min_minutes <= max_minutes
    )
);

CREATE INDEX idx_lessons_level ON lessons(level_id);
CREATE INDEX idx_lessons_type ON lessons(lesson_type);
CREATE INDEX idx_lessons_status ON lessons(status);
CREATE INDEX idx_lessons_difficulty ON lessons(difficulty);
CREATE INDEX idx_lessons_sort ON lessons(level_id, sort_order);
CREATE INDEX idx_lessons_unit ON lessons(level_id, unit_number, sort_order);
CREATE INDEX idx_lessons_slug ON lessons(slug);
CREATE INDEX idx_lessons_primary_skill ON lessons(primary_skill);
CREATE INDEX idx_lessons_active ON lessons(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_lessons_featured ON lessons(is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_lessons_free ON lessons(is_free) WHERE is_free = TRUE;
CREATE INDEX idx_lessons_published_at ON lessons(published_at DESC) WHERE published_at IS NOT NULL;
CREATE INDEX idx_lessons_created_by ON lessons(created_by) WHERE created_by IS NOT NULL;
CREATE INDEX idx_lessons_xp_reward ON lessons(xp_reward);
CREATE INDEX idx_lessons_tags ON lessons USING gin(tags);
CREATE INDEX idx_lessons_topics ON lessons USING gin(topics);
CREATE INDEX idx_lessons_vocabulary ON lessons USING gin(vocabulary_words);

-- Full-text search
CREATE INDEX idx_lessons_search ON lessons USING gin(
    to_tsvector('english', coalesce(title,'') || ' ' || coalesce(description,'') || ' ' || coalesce(summary,''))
);

CREATE TRIGGER trigger_lessons_updated_at
    BEFORE UPDATE ON lessons
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Auto-update level's total_lessons count
CREATE OR REPLACE FUNCTION update_level_lesson_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE levels SET total_lessons = total_lessons + 1 WHERE id = NEW.level_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE levels SET total_lessons = total_lessons - 1 WHERE id = OLD.level_id;
    ELSIF TG_OP = 'UPDATE' AND OLD.level_id != NEW.level_id THEN
        UPDATE levels SET total_lessons = total_lessons - 1 WHERE id = OLD.level_id;
        UPDATE levels SET total_lessons = total_lessons + 1 WHERE id = NEW.level_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_lesson_count
    AFTER INSERT OR UPDATE OR DELETE ON lessons
    FOR EACH ROW
    EXECUTE FUNCTION update_level_lesson_count();

COMMENT ON TABLE lessons IS 'Individual learning lessons organized by level and type';
COMMENT ON COLUMN lessons.content IS 'JSON structure containing lesson content: slides, exercises, media references';
COMMENT ON COLUMN lessons.xp_reward IS 'XP awarded on lesson completion';

COMMIT;
