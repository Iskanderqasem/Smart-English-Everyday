-- Migration: 002_create_levels.sql
-- Description: Create levels table (1-10 proficiency levels)
-- Created: 2024-01-01

BEGIN;

CREATE TYPE cefr_level AS ENUM ('A1', 'A2', 'B1', 'B2', 'C1', 'C2');

CREATE TABLE IF NOT EXISTS levels (
    id                  SERIAL PRIMARY KEY,
    level_number        INTEGER NOT NULL UNIQUE CHECK (level_number BETWEEN 1 AND 10),
    name                VARCHAR(100) NOT NULL,
    display_name        VARCHAR(100) NOT NULL,
    description         TEXT NOT NULL,
    short_description   VARCHAR(255),
    cefr_equivalent     cefr_level NOT NULL,
    required_xp         INTEGER NOT NULL CHECK (required_xp >= 0),
    xp_to_next_level    INTEGER CHECK (xp_to_next_level > 0),
    color_hex           VARCHAR(7) NOT NULL DEFAULT '#4CAF50',
    color_gradient_start VARCHAR(7),
    color_gradient_end  VARCHAR(7),
    icon_name           VARCHAR(50),
    icon_url            TEXT,
    badge_url           TEXT,
    unlock_message      TEXT,

    -- Level content stats
    total_lessons       INTEGER NOT NULL DEFAULT 0,
    total_words         INTEGER NOT NULL DEFAULT 0,
    total_exercises     INTEGER NOT NULL DEFAULT 0,
    estimated_hours     INTEGER,

    -- Features unlocked at this level
    features_unlocked   TEXT[] DEFAULT '{}',
    topics              TEXT[] DEFAULT '{}',
    grammar_focus       TEXT[] DEFAULT '{}',
    skills_focus        TEXT[] DEFAULT '{}',

    -- Passing criteria
    min_accuracy_percent INTEGER NOT NULL DEFAULT 70 CHECK (min_accuracy_percent BETWEEN 50 AND 100),
    min_lessons_to_pass  INTEGER NOT NULL DEFAULT 1,

    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order          INTEGER NOT NULL DEFAULT 0,
    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_levels_level_number ON levels(level_number);
CREATE INDEX idx_levels_cefr ON levels(cefr_equivalent);
CREATE INDEX idx_levels_active ON levels(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_levels_sort ON levels(sort_order);

CREATE TRIGGER trigger_levels_updated_at
    BEFORE UPDATE ON levels
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE levels IS 'Proficiency levels 1-10 mapping to CEFR framework (A1 through C2)';
COMMENT ON COLUMN levels.required_xp IS 'Total XP needed to reach this level';
COMMENT ON COLUMN levels.xp_to_next_level IS 'XP needed from this level to advance to next';
COMMENT ON COLUMN levels.cefr_equivalent IS 'Equivalent Common European Framework of Reference level';

COMMIT;
