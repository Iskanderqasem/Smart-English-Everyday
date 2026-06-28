-- Migration: 001_create_users.sql
-- Description: Create users table with all required fields
-- Created: 2024-01-01

BEGIN;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create enum types
CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin', 'super_admin');
CREATE TYPE auth_provider AS ENUM ('email', 'google', 'facebook', 'apple');
CREATE TYPE subscription_tier AS ENUM ('free', 'basic', 'premium', 'enterprise');
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended', 'deleted', 'pending_verification');
CREATE TYPE gender_type AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email                   VARCHAR(255) NOT NULL UNIQUE,
    email_verified          BOOLEAN NOT NULL DEFAULT FALSE,
    email_verified_at       TIMESTAMPTZ,
    password_hash           VARCHAR(255),
    phone                   VARCHAR(20) UNIQUE,
    phone_verified          BOOLEAN NOT NULL DEFAULT FALSE,
    phone_verified_at       TIMESTAMPTZ,

    -- Profile information
    first_name              VARCHAR(100) NOT NULL,
    last_name               VARCHAR(100),
    display_name            VARCHAR(100),
    username                VARCHAR(50) UNIQUE,
    avatar_url              TEXT,
    bio                     TEXT,
    date_of_birth           DATE,
    gender                  gender_type,
    nationality             VARCHAR(100),
    native_language         VARCHAR(50),
    timezone                VARCHAR(50) DEFAULT 'UTC',
    locale                  VARCHAR(10) DEFAULT 'en',

    -- Authentication
    role                    user_role NOT NULL DEFAULT 'student',
    auth_provider           auth_provider NOT NULL DEFAULT 'email',
    provider_id             VARCHAR(255),
    provider_data           JSONB DEFAULT '{}',

    -- Subscription
    subscription_tier       subscription_tier NOT NULL DEFAULT 'free',
    subscription_start_at   TIMESTAMPTZ,
    subscription_end_at     TIMESTAMPTZ,
    stripe_customer_id      VARCHAR(255),
    stripe_subscription_id  VARCHAR(255),

    -- Learning profile
    current_level_id        INTEGER REFERENCES levels(id) ON DELETE SET NULL,
    target_level_id         INTEGER REFERENCES levels(id) ON DELETE SET NULL,
    daily_goal_minutes      INTEGER NOT NULL DEFAULT 15,
    weekly_goal_days        INTEGER NOT NULL DEFAULT 5 CHECK (weekly_goal_days BETWEEN 1 AND 7),
    learning_goals          TEXT[],
    interests               TEXT[],
    preferred_topics        TEXT[],

    -- Gamification
    total_xp                INTEGER NOT NULL DEFAULT 0 CHECK (total_xp >= 0),
    current_streak_days     INTEGER NOT NULL DEFAULT 0 CHECK (current_streak_days >= 0),
    longest_streak_days     INTEGER NOT NULL DEFAULT 0 CHECK (longest_streak_days >= 0),
    streak_last_activity    DATE,
    total_lessons_completed INTEGER NOT NULL DEFAULT 0,
    total_words_learned     INTEGER NOT NULL DEFAULT 0,
    total_minutes_studied   INTEGER NOT NULL DEFAULT 0,
    gems                    INTEGER NOT NULL DEFAULT 0 CHECK (gems >= 0),
    hearts                  INTEGER NOT NULL DEFAULT 5 CHECK (hearts BETWEEN 0 AND 5),
    hearts_last_refill      TIMESTAMPTZ,

    -- Notifications preferences
    notif_email_enabled     BOOLEAN NOT NULL DEFAULT TRUE,
    notif_push_enabled      BOOLEAN NOT NULL DEFAULT TRUE,
    notif_sms_enabled       BOOLEAN NOT NULL DEFAULT FALSE,
    notif_lesson_reminder   BOOLEAN NOT NULL DEFAULT TRUE,
    notif_streak_reminder   BOOLEAN NOT NULL DEFAULT TRUE,
    notif_achievement        BOOLEAN NOT NULL DEFAULT TRUE,
    notif_newsletter        BOOLEAN NOT NULL DEFAULT FALSE,
    reminder_time           TIME DEFAULT '18:00:00',

    -- Security
    two_factor_enabled      BOOLEAN NOT NULL DEFAULT FALSE,
    two_factor_secret       VARCHAR(32),
    two_factor_backup_codes TEXT[],
    last_login_at           TIMESTAMPTZ,
    last_login_ip           INET,
    last_login_user_agent   TEXT,
    failed_login_attempts   INTEGER NOT NULL DEFAULT 0,
    locked_until            TIMESTAMPTZ,

    -- Tokens
    password_reset_token    VARCHAR(255),
    password_reset_expires  TIMESTAMPTZ,
    email_verify_token      VARCHAR(255),
    email_verify_expires    TIMESTAMPTZ,
    refresh_token_family    UUID DEFAULT uuid_generate_v4(),

    -- FCM / Push notifications
    fcm_tokens              TEXT[] DEFAULT '{}',
    device_info             JSONB DEFAULT '[]',

    -- Social
    referral_code           VARCHAR(20) UNIQUE DEFAULT upper(substr(md5(random()::text), 1, 8)),
    referred_by             UUID REFERENCES users(id) ON DELETE SET NULL,
    referral_count          INTEGER NOT NULL DEFAULT 0,

    -- Status
    status                  user_status NOT NULL DEFAULT 'pending_verification',
    deleted_at              TIMESTAMPTZ,
    deleted_reason          TEXT,

    -- Metadata
    extra_data              JSONB DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username) WHERE username IS NOT NULL;
CREATE INDEX idx_users_phone ON users(phone) WHERE phone IS NOT NULL;
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_subscription_tier ON users(subscription_tier);
CREATE INDEX idx_users_current_level ON users(current_level_id);
CREATE INDEX idx_users_total_xp ON users(total_xp DESC);
CREATE INDEX idx_users_streak ON users(current_streak_days DESC);
CREATE INDEX idx_users_referred_by ON users(referred_by) WHERE referred_by IS NOT NULL;
CREATE INDEX idx_users_provider ON users(auth_provider, provider_id) WHERE provider_id IS NOT NULL;
CREATE INDEX idx_users_created_at ON users(created_at DESC);
CREATE INDEX idx_users_stripe_customer ON users(stripe_customer_id) WHERE stripe_customer_id IS NOT NULL;
CREATE INDEX idx_users_referral_code ON users(referral_code);
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NOT NULL;

-- Full-text search index
CREATE INDEX idx_users_search ON users USING gin(
    to_tsvector('english', coalesce(first_name,'') || ' ' || coalesce(last_name,'') || ' ' || coalesce(display_name,'') || ' ' || coalesce(username,''))
);

-- Trigram index for LIKE searches
CREATE INDEX idx_users_email_trgm ON users USING gin(email gin_trgm_ops);
CREATE INDEX idx_users_name_trgm ON users USING gin(
    (coalesce(first_name,'') || ' ' || coalesce(last_name,'')) gin_trgm_ops
);

-- Auto-update updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Soft delete trigger (set status to deleted when deleted_at is set)
CREATE OR REPLACE FUNCTION handle_user_soft_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
        NEW.status = 'deleted';
        -- Anonymize PII
        NEW.email = 'deleted_' || NEW.id || '@deleted.com';
        NEW.phone = NULL;
        NEW.first_name = 'Deleted';
        NEW.last_name = 'User';
        NEW.avatar_url = NULL;
        NEW.bio = NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_soft_delete
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION handle_user_soft_delete();

-- Comments
COMMENT ON TABLE users IS 'Main users table storing all user accounts for Smart English Everyday';
COMMENT ON COLUMN users.total_xp IS 'Total experience points earned across all activities';
COMMENT ON COLUMN users.current_streak_days IS 'Current consecutive days of activity';
COMMENT ON COLUMN users.hearts IS 'Lives system: lose hearts on wrong answers, max 5, refills every 4 hours';
COMMENT ON COLUMN users.gems IS 'Premium in-app currency earned from achievements';
COMMENT ON COLUMN users.referral_code IS 'Unique code for referral program';

COMMIT;
