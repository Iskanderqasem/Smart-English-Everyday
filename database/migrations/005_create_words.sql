-- Migration: 005_create_words.sql
-- Description: Vocabulary words table with topic, CEFR level, audio, images, definitions, examples
-- Created: 2024-01-01

BEGIN;

CREATE TYPE word_part_of_speech AS ENUM (
    'noun', 'verb', 'adjective', 'adverb', 'pronoun', 'preposition',
    'conjunction', 'interjection', 'article', 'determiner', 'phrasal_verb',
    'idiom', 'collocation', 'expression'
);

CREATE TYPE word_register AS ENUM ('formal', 'informal', 'neutral', 'slang', 'technical', 'literary', 'archaic');
CREATE TYPE word_frequency AS ENUM ('very_common', 'common', 'uncommon', 'rare', 'very_rare');

CREATE TABLE IF NOT EXISTS words (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    word                VARCHAR(255) NOT NULL,
    word_normalized     VARCHAR(255) NOT NULL GENERATED ALWAYS AS (lower(trim(word))) STORED,
    slug                VARCHAR(255) UNIQUE NOT NULL,

    -- Classification
    part_of_speech      word_part_of_speech NOT NULL,
    cefr_level          cefr_level NOT NULL,
    level_id            INTEGER REFERENCES levels(id) ON DELETE SET NULL,
    topic               VARCHAR(100) NOT NULL,
    subtopic            VARCHAR(100),
    topics              TEXT[] DEFAULT '{}',
    tags                TEXT[] DEFAULT '{}',
    frequency           word_frequency NOT NULL DEFAULT 'common',
    register            word_register NOT NULL DEFAULT 'neutral',
    is_irregular        BOOLEAN NOT NULL DEFAULT FALSE,
    is_phrasal          BOOLEAN NOT NULL DEFAULT FALSE,

    -- Phonetics
    phonetic_ipa        VARCHAR(255),
    phonetic_respelling VARCHAR(255),
    syllables           VARCHAR(255),
    syllable_count      INTEGER,
    stress_pattern      VARCHAR(50),
    rhymes_with         TEXT[] DEFAULT '{}',

    -- Media
    audio_url           TEXT,
    audio_us_url        TEXT,
    audio_uk_url        TEXT,
    audio_au_url        TEXT,
    image_url           TEXT,
    image_alt           TEXT,
    video_url           TEXT,
    animation_url       TEXT,

    -- Definitions (array of definition objects)
    definitions         JSONB NOT NULL DEFAULT '[]',
    -- Structure: [{"sense": 1, "definition": "...", "part_of_speech": "...", "usage_note": "..."}]

    -- Examples (array of example objects)
    examples            JSONB NOT NULL DEFAULT '[]',
    -- Structure: [{"sentence": "...", "translation": "...", "source": "...", "audio_url": "..."}]

    -- Word relationships
    synonyms            TEXT[] DEFAULT '{}',
    antonyms            TEXT[] DEFAULT '{}',
    related_words       TEXT[] DEFAULT '{}',
    collocations        TEXT[] DEFAULT '{}',
    word_family         JSONB DEFAULT '{}',
    -- Structure: {"noun": "...", "verb": "...", "adjective": "...", "adverb": "..."}

    -- Grammar
    plural_form         VARCHAR(255),
    verb_forms          JSONB DEFAULT '{}',
    -- Structure: {"base": "...", "past": "...", "past_participle": "...", "present_participle": "...", "third_person": "..."}
    comparative_form    VARCHAR(255),
    superlative_form    VARCHAR(255),
    grammar_notes       TEXT,
    usage_notes         TEXT,
    common_mistakes     TEXT[] DEFAULT '{}',

    -- Contextual information
    etymology           TEXT,
    origin_language     VARCHAR(50),
    cultural_notes      TEXT,
    memory_tip          TEXT,
    mnemonic            TEXT,

    -- Translations
    translations        JSONB DEFAULT '{}',
    -- Structure: {"ar": "...", "fr": "...", "es": "...", "de": "...", "zh": "..."}

    -- Sentences / practice
    example_dialogue    JSONB DEFAULT '[]',
    fill_in_blank       TEXT[] DEFAULT '{}',

    -- Stats
    times_practiced     INTEGER NOT NULL DEFAULT 0,
    times_correct       INTEGER NOT NULL DEFAULT 0,
    difficulty_rating   DECIMAL(3,2),
    learner_count       INTEGER NOT NULL DEFAULT 0,

    -- Status
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    is_verified         BOOLEAN NOT NULL DEFAULT FALSE,
    ai_generated        BOOLEAN NOT NULL DEFAULT FALSE,
    source              VARCHAR(100),
    reviewed_by         UUID REFERENCES users(id) ON DELETE SET NULL,
    reviewed_at         TIMESTAMPTZ,

    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User vocabulary (words saved/learned by users)
CREATE TABLE IF NOT EXISTS user_vocabulary (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    word_id             UUID NOT NULL REFERENCES words(id) ON DELETE CASCADE,

    -- SRS (Spaced Repetition System)
    srs_level           INTEGER NOT NULL DEFAULT 0 CHECK (srs_level BETWEEN 0 AND 10),
    ease_factor         DECIMAL(4,2) NOT NULL DEFAULT 2.50,
    interval_days       INTEGER NOT NULL DEFAULT 1,
    next_review_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_reviewed_at    TIMESTAMPTZ,
    review_count        INTEGER NOT NULL DEFAULT 0,
    correct_count       INTEGER NOT NULL DEFAULT 0,
    incorrect_count     INTEGER NOT NULL DEFAULT 0,
    lapse_count         INTEGER NOT NULL DEFAULT 0,

    -- Status
    is_learned          BOOLEAN NOT NULL DEFAULT FALSE,
    is_mastered         BOOLEAN NOT NULL DEFAULT FALSE,
    learned_at          TIMESTAMPTZ,
    mastered_at         TIMESTAMPTZ,
    is_bookmarked       BOOLEAN NOT NULL DEFAULT FALSE,
    is_ignored          BOOLEAN NOT NULL DEFAULT FALSE,

    -- Personal notes
    personal_note       TEXT,
    personal_example    TEXT,
    personal_mnemonic   TEXT,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(user_id, word_id)
);

CREATE INDEX idx_words_word ON words(word_normalized);
CREATE INDEX idx_words_cefr ON words(cefr_level);
CREATE INDEX idx_words_level ON words(level_id);
CREATE INDEX idx_words_topic ON words(topic);
CREATE INDEX idx_words_pos ON words(part_of_speech);
CREATE INDEX idx_words_frequency ON words(frequency);
CREATE INDEX idx_words_register ON words(register);
CREATE INDEX idx_words_active ON words(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_words_slug ON words(slug);
CREATE INDEX idx_words_topics ON words USING gin(topics);
CREATE INDEX idx_words_tags ON words USING gin(tags);
CREATE INDEX idx_words_synonyms ON words USING gin(synonyms);
CREATE INDEX idx_words_antonyms ON words USING gin(antonyms);
CREATE INDEX idx_words_search ON words USING gin(
    to_tsvector('english', word || ' ' || coalesce(array_to_string(synonyms, ' '), '') || ' ' || coalesce(topic, ''))
);

CREATE INDEX idx_user_vocab_user ON user_vocabulary(user_id);
CREATE INDEX idx_user_vocab_word ON user_vocabulary(word_id);
CREATE INDEX idx_user_vocab_review ON user_vocabulary(user_id, next_review_at) WHERE is_mastered = FALSE;
CREATE INDEX idx_user_vocab_learned ON user_vocabulary(user_id, is_learned);
CREATE INDEX idx_user_vocab_bookmarked ON user_vocabulary(user_id) WHERE is_bookmarked = TRUE;
CREATE INDEX idx_user_vocab_srs_level ON user_vocabulary(srs_level);

CREATE TRIGGER trigger_words_updated_at
    BEFORE UPDATE ON words
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_user_vocabulary_updated_at
    BEFORE UPDATE ON user_vocabulary
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Update user total_words_learned when word is marked learned
CREATE OR REPLACE FUNCTION update_user_word_count()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_learned = TRUE AND OLD.is_learned = FALSE THEN
        UPDATE users SET total_words_learned = total_words_learned + 1 WHERE id = NEW.user_id;
        NEW.learned_at = NOW();
    ELSIF NEW.is_mastered = TRUE AND OLD.is_mastered = FALSE THEN
        NEW.mastered_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_user_word_count
    BEFORE UPDATE ON user_vocabulary
    FOR EACH ROW
    EXECUTE FUNCTION update_user_word_count();

COMMENT ON TABLE words IS 'Master vocabulary word list with full linguistic data';
COMMENT ON TABLE user_vocabulary IS 'Per-user vocabulary tracking with spaced repetition data';
COMMENT ON COLUMN words.definitions IS 'JSON array of definition objects with sense, definition text, usage notes';
COMMENT ON COLUMN words.examples IS 'JSON array of example sentences with translations and audio';
COMMENT ON COLUMN words.verb_forms IS 'Verb conjugation forms: base, past, past participle, present participle, third person';
COMMENT ON COLUMN user_vocabulary.srs_level IS 'Spaced repetition level 0-10; higher = longer interval before next review';
COMMENT ON COLUMN user_vocabulary.ease_factor IS 'SM-2 algorithm ease factor; starts at 2.5, decreases on wrong answers';

COMMIT;
