-- Migration: 010_create_notifications.sql
-- Description: Notifications table with delivery tracking
-- Created: 2024-01-01

BEGIN;

CREATE TYPE notification_type AS ENUM (
    'lesson_reminder', 'streak_warning', 'streak_broken', 'streak_milestone',
    'achievement_earned', 'level_up', 'xp_milestone', 'friend_activity',
    'challenge_invite', 'challenge_result', 'new_content', 'system',
    'promotional', 'teacher_feedback', 'assessment_reminder',
    'subscription_expiry', 'hearts_refilled', 'leaderboard_update',
    'weekly_report', 'motivational', 'account_security', 'custom'
);

CREATE TYPE notification_status AS ENUM ('pending', 'sent', 'delivered', 'read', 'failed', 'cancelled');
CREATE TYPE notification_channel AS ENUM ('push', 'email', 'sms', 'in_app', 'all');
CREATE TYPE notification_priority AS ENUM ('low', 'normal', 'high', 'urgent');

CREATE TABLE IF NOT EXISTS notifications (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Content
    notification_type   notification_type NOT NULL,
    title               VARCHAR(255) NOT NULL,
    body                TEXT NOT NULL,
    subtitle            VARCHAR(255),
    short_body          VARCHAR(500),
    rich_body           TEXT,
    -- HTML/Markdown for email

    -- Channels
    channel             notification_channel NOT NULL DEFAULT 'in_app',
    priority            notification_priority NOT NULL DEFAULT 'normal',

    -- Status
    status              notification_status NOT NULL DEFAULT 'pending',
    sent_at             TIMESTAMPTZ,
    delivered_at        TIMESTAMPTZ,
    read_at             TIMESTAMPTZ,
    failed_at           TIMESTAMPTZ,
    failure_reason      TEXT,
    retry_count         INTEGER NOT NULL DEFAULT 0,
    next_retry_at       TIMESTAMPTZ,

    -- Action / Deep link
    action_url          TEXT,
    action_label        VARCHAR(100),
    action_type         VARCHAR(50),
    deep_link           TEXT,
    -- e.g., app://lessons/123 or https://...

    -- Media
    icon_url            TEXT,
    image_url           TEXT,
    badge_count         INTEGER,
    sound               VARCHAR(50) DEFAULT 'default',

    -- Related entity
    entity_type         VARCHAR(50),
    entity_id           UUID,
    -- e.g., "achievement" + achievement_id

    -- Scheduling
    scheduled_at        TIMESTAMPTZ,
    expires_at          TIMESTAMPTZ,

    -- Push notification specific
    fcm_message_id      VARCHAR(255),
    apns_message_id     VARCHAR(255),
    push_data           JSONB DEFAULT '{}',

    -- Email specific
    email_subject       VARCHAR(255),
    email_template_id   VARCHAR(100),
    email_provider_id   VARCHAR(255),

    -- Batching
    batch_id            UUID,
    is_batch_summary    BOOLEAN NOT NULL DEFAULT FALSE,

    -- Targeting
    campaign_id         UUID,
    segment             VARCHAR(100),
    ab_variant          VARCHAR(20),

    is_dismissible      BOOLEAN NOT NULL DEFAULT TRUE,
    extra_data          JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Notification templates
CREATE TABLE IF NOT EXISTS notification_templates (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100) NOT NULL UNIQUE,
    notification_type notification_type NOT NULL,
    channel         notification_channel NOT NULL DEFAULT 'all',
    title_template  TEXT NOT NULL,
    body_template   TEXT NOT NULL,
    rich_template   TEXT,
    variables       TEXT[] DEFAULT '{}',
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    extra_data      JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(notification_type);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_channel ON notifications(channel);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, status) WHERE status != 'read';
CREATE INDEX idx_notifications_user_status ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_scheduled ON notifications(scheduled_at) WHERE scheduled_at IS NOT NULL AND status = 'pending';
CREATE INDEX idx_notifications_retry ON notifications(next_retry_at) WHERE status = 'failed' AND retry_count < 3;
CREATE INDEX idx_notifications_entity ON notifications(entity_type, entity_id) WHERE entity_id IS NOT NULL;
CREATE INDEX idx_notifications_batch ON notifications(batch_id) WHERE batch_id IS NOT NULL;
CREATE INDEX idx_notifications_campaign ON notifications(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

CREATE TRIGGER trigger_notifications_updated_at
    BEFORE UPDATE ON notifications
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_notification_templates_updated_at
    BEFORE UPDATE ON notification_templates
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE notifications IS 'User notification inbox with multi-channel delivery tracking';
COMMENT ON TABLE notification_templates IS 'Reusable notification templates with variable substitution';
COMMENT ON COLUMN notifications.deep_link IS 'Mobile deep link URL for navigating to specific content';

COMMIT;
