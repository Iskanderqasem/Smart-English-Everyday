-- Migration: 011_create_chat_messages.sql
-- Description: AI tutor chat messages and conversation threads
-- Created: 2024-01-01

BEGIN;

CREATE TYPE message_role AS ENUM ('user', 'assistant', 'system', 'tool');
CREATE TYPE message_status AS ENUM ('pending', 'sent', 'delivered', 'read', 'failed', 'deleted');
CREATE TYPE conversation_type AS ENUM (
    'general_tutor', 'grammar_help', 'vocabulary_help', 'writing_coach',
    'speaking_practice', 'lesson_help', 'pronunciation', 'pronunciation_correction',
    'translation', 'cultural_info', 'exam_prep', 'free_conversation'
);

CREATE TABLE IF NOT EXISTS conversations (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id           UUID REFERENCES lessons(id) ON DELETE SET NULL,
    level_id            INTEGER REFERENCES levels(id) ON DELETE SET NULL,

    conversation_type   conversation_type NOT NULL DEFAULT 'general_tutor',
    title               VARCHAR(255),
    summary             TEXT,
    topic               VARCHAR(100),

    -- AI configuration
    ai_model            VARCHAR(100) NOT NULL DEFAULT 'claude-3-5-sonnet',
    ai_persona          VARCHAR(50) DEFAULT 'tutor',
    system_prompt       TEXT,
    temperature         DECIMAL(3,2) DEFAULT 0.7,
    context_window      JSONB DEFAULT '[]',
    -- Rolling context for the AI

    -- Stats
    message_count       INTEGER NOT NULL DEFAULT 0,
    user_message_count  INTEGER NOT NULL DEFAULT 0,
    ai_message_count    INTEGER NOT NULL DEFAULT 0,
    total_tokens_used   INTEGER NOT NULL DEFAULT 0,
    total_cost_usd      DECIMAL(10,6) NOT NULL DEFAULT 0,

    -- Status
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    is_archived         BOOLEAN NOT NULL DEFAULT FALSE,
    is_pinned           BOOLEAN NOT NULL DEFAULT FALSE,
    last_message_at     TIMESTAMPTZ,
    archived_at         TIMESTAMPTZ,

    xp_earned           INTEGER NOT NULL DEFAULT 0,
    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS chat_messages (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id     UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    role                message_role NOT NULL,
    status              message_status NOT NULL DEFAULT 'sent',

    -- Content
    content             TEXT NOT NULL,
    content_type        VARCHAR(50) NOT NULL DEFAULT 'text',
    -- text, markdown, html, audio, image, mixed
    formatted_content   TEXT,
    -- Markdown/HTML formatted version

    -- Attachments
    attachments         JSONB DEFAULT '[]',
    -- [{type: "image", url: "...", name: "..."}, {type: "audio", url: "..."}]
    audio_url           TEXT,
    image_url           TEXT,
    audio_duration_secs DECIMAL(6,2),

    -- Grammar/vocabulary context
    grammar_points      TEXT[] DEFAULT '{}',
    vocabulary_words    UUID[] DEFAULT '{}',
    corrections         JSONB DEFAULT '[]',
    -- [{original: "...", corrected: "...", explanation: "...", type: "grammar|vocabulary|spelling"}]
    suggestions         JSONB DEFAULT '[]',
    translation         TEXT,
    translation_language VARCHAR(10),

    -- AI metadata (for assistant messages)
    ai_model            VARCHAR(100),
    ai_tokens_prompt    INTEGER,
    ai_tokens_completion INTEGER,
    ai_tokens_total     INTEGER,
    ai_cost_usd         DECIMAL(10,6),
    ai_latency_ms       INTEGER,
    ai_finish_reason    VARCHAR(50),
    ai_raw_response     JSONB,

    -- Message chain
    parent_message_id   UUID REFERENCES chat_messages(id) ON DELETE SET NULL,
    is_reply            BOOLEAN NOT NULL DEFAULT FALSE,

    -- Tool calls (function calling)
    tool_calls          JSONB DEFAULT '[]',
    tool_results        JSONB DEFAULT '[]',

    -- User interaction
    is_liked            BOOLEAN,
    is_bookmarked       BOOLEAN NOT NULL DEFAULT FALSE,
    user_rating         SMALLINT CHECK (user_rating BETWEEN 1 AND 5),
    user_feedback       TEXT,

    -- Moderation
    is_flagged          BOOLEAN NOT NULL DEFAULT FALSE,
    flag_reason         TEXT,
    is_hidden           BOOLEAN NOT NULL DEFAULT FALSE,

    deleted_at          TIMESTAMPTZ,
    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- AI tutor personas
CREATE TABLE IF NOT EXISTS ai_personas (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(50) NOT NULL UNIQUE,
    display_name    VARCHAR(100) NOT NULL,
    description     TEXT,
    avatar_url      TEXT,
    personality     TEXT NOT NULL,
    system_prompt   TEXT NOT NULL,
    teaching_style  VARCHAR(50),
    language_focus  TEXT[] DEFAULT '{}',
    tone            VARCHAR(50) DEFAULT 'friendly',
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    is_premium      BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    extra_data      JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_conversations_user ON conversations(user_id);
CREATE INDEX idx_conversations_type ON conversations(conversation_type);
CREATE INDEX idx_conversations_lesson ON conversations(lesson_id);
CREATE INDEX idx_conversations_active ON conversations(user_id, is_active) WHERE is_active = TRUE;
CREATE INDEX idx_conversations_last_msg ON conversations(user_id, last_message_at DESC);
CREATE INDEX idx_conversations_pinned ON conversations(user_id) WHERE is_pinned = TRUE;
CREATE INDEX idx_conversations_archived ON conversations(user_id, archived_at DESC) WHERE is_archived = TRUE;

CREATE INDEX idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX idx_chat_messages_user ON chat_messages(user_id);
CREATE INDEX idx_chat_messages_role ON chat_messages(conversation_id, role);
CREATE INDEX idx_chat_messages_created ON chat_messages(conversation_id, created_at ASC);
CREATE INDEX idx_chat_messages_bookmarked ON chat_messages(user_id) WHERE is_bookmarked = TRUE;
CREATE INDEX idx_chat_messages_flagged ON chat_messages(is_flagged) WHERE is_flagged = TRUE;
CREATE INDEX idx_chat_messages_parent ON chat_messages(parent_message_id) WHERE parent_message_id IS NOT NULL;

CREATE TRIGGER trigger_conversations_updated_at
    BEFORE UPDATE ON conversations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_chat_messages_updated_at
    BEFORE UPDATE ON chat_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_ai_personas_updated_at
    BEFORE UPDATE ON ai_personas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Update conversation stats on new message
CREATE OR REPLACE FUNCTION update_conversation_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversations
    SET
        message_count = message_count + 1,
        user_message_count = user_message_count + CASE WHEN NEW.role = 'user' THEN 1 ELSE 0 END,
        ai_message_count = ai_message_count + CASE WHEN NEW.role = 'assistant' THEN 1 ELSE 0 END,
        total_tokens_used = total_tokens_used + COALESCE(NEW.ai_tokens_total, 0),
        total_cost_usd = total_cost_usd + COALESCE(NEW.ai_cost_usd, 0),
        last_message_at = NOW(),
        updated_at = NOW()
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_conversation_stats
    AFTER INSERT ON chat_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_conversation_stats();

COMMENT ON TABLE conversations IS 'AI tutor conversation threads per user';
COMMENT ON TABLE chat_messages IS 'Individual messages within AI tutor conversations';
COMMENT ON TABLE ai_personas IS 'AI tutor personality configurations';
COMMENT ON COLUMN chat_messages.corrections IS 'Grammar/vocabulary corrections suggested by AI for user messages';
COMMENT ON COLUMN conversations.total_cost_usd IS 'Running total of AI API cost for this conversation';

COMMIT;
