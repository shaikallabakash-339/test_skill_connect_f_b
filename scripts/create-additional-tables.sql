-- ============================================================================
-- SKILL CONNECT - ADDITIONAL DATABASE TABLES
-- ============================================================================
-- Run this script to add tables for:
-- - Email logging and SendPulse limit tracking
-- - Real-time messaging system
-- - User connections and premium features
-- - Admin notifications
-- - Donations tracking
-- - Old age homes and orphans management
-- ============================================================================

-- Ensure UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- EMAIL LOGGING TABLE - Track SendPulse usage and limits
-- ============================================================================
CREATE TABLE IF NOT EXISTS email_logs (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  recipient_email VARCHAR(255) NOT NULL,
  subject VARCHAR(255),
  body TEXT,
  service VARCHAR(50) NOT NULL DEFAULT 'mailpit', -- 'sendpulse', 'mailpit', 'mailpilt'
  status VARCHAR(50) DEFAULT 'sent', -- 'sent', 'failed', 'bounced'
  error_message TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_service_created (service, created_at),
  INDEX idx_recipient_created (recipient_email, created_at)
);

-- ============================================================================
-- REAL-TIME MESSAGING TABLE - User-to-user messages
-- ============================================================================
CREATE TABLE IF NOT EXISTS user_messages (
  id SERIAL PRIMARY KEY,
  sender_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  message_text TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_sender_receiver (sender_id, receiver_id),
  INDEX idx_receiver_created (receiver_id, created_at),
  INDEX idx_is_read (is_read)
);

-- ============================================================================
-- USER CONNECTIONS TABLE - Track connections for free tier limits
-- ============================================================================
CREATE TABLE IF NOT EXISTS user_connections (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  connected_with_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'accepted', 'rejected', 'blocked'
  created_at TIMESTAMP DEFAULT NOW(),
  accepted_at TIMESTAMP,
  UNIQUE(user_id, connected_with_id),
  INDEX idx_user_status (user_id, status),
  INDEX idx_connected_with (connected_with_id)
);

-- ============================================================================
-- ADMIN NOTIFICATIONS TABLE - Messages from admin to users
-- ============================================================================
CREATE TABLE IF NOT EXISTS admin_notifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  admin_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  title VARCHAR(255),
  message TEXT NOT NULL,
  category VARCHAR(50), -- 'general', 'employed', 'pursuing', 'graduated'
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_user_is_read (user_id, is_read),
  INDEX idx_category (category)
);

-- ============================================================================
-- DONATIONS TABLE - Track donations to homes and orphans
-- ============================================================================
CREATE TABLE IF NOT EXISTS donations (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  amount DECIMAL(10, 2) NOT NULL,
  donation_type VARCHAR(50) NOT NULL, -- 'home', 'orphan', 'general'
  entity_id INTEGER, -- ID of home/orphan (if applicable)
  payment_method VARCHAR(50), -- 'upi', 'card', 'wallet'
  payment_screenshot_url VARCHAR(500), -- MinIO URL
  transaction_id VARCHAR(255),
  status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'confirmed', 'rejected'
  donor_email VARCHAR(255),
  donor_name VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  confirmed_at TIMESTAMP,
  INDEX idx_status (status),
  INDEX idx_created (created_at),
  INDEX idx_entity (donation_type, entity_id)
);

-- ============================================================================
-- OLD AGE HOMES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS old_age_homes (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  location VARCHAR(255),
  description TEXT,
  image_url VARCHAR(500), -- MinIO URL
  donation_qr_url VARCHAR(500), -- MinIO URL for QR code
  contact_email VARCHAR(255),
  contact_phone VARCHAR(20),
  total_residents INTEGER,
  total_donations DECIMAL(10, 2) DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_active (is_active)
);

-- ============================================================================
-- ORPHANS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS orphans (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  age INTEGER,
  story TEXT,
  image_url VARCHAR(500), -- MinIO URL
  donation_qr_url VARCHAR(500), -- MinIO URL for QR code
  status VARCHAR(50) DEFAULT 'active', -- 'active', 'sponsored', 'completed'
  total_donations DECIMAL(10, 2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_status (status)
);

-- ============================================================================
-- QR CODES TABLE - Store generated QR codes
-- ============================================================================
CREATE TABLE IF NOT EXISTS qr_codes (
  id SERIAL PRIMARY KEY,
  entity_type VARCHAR(50) NOT NULL, -- 'home', 'orphan', 'general'
  entity_id INTEGER,
  qr_code_url VARCHAR(500) NOT NULL, -- MinIO URL
  target_url VARCHAR(500), -- URL QR code points to
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_entity (entity_type, entity_id)
);

-- ============================================================================
-- ADMIN MESSAGES TEMPLATE - Pre-defined templates for bulk sending
-- ============================================================================
CREATE TABLE IF NOT EXISTS message_templates (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  subject VARCHAR(255),
  body TEXT NOT NULL,
  category VARCHAR(50), -- 'employed', 'pursuing', 'graduated', 'general'
  variables TEXT, -- JSON of variables like {name}, {status}
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_category (category)
);

-- ============================================================================
-- SUBSCRIPTION PLANS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS subscription_plans (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE, -- 'free', 'premium', 'pro'
  price DECIMAL(10, 2),
  duration_days INTEGER, -- NULL for lifetime
  max_connections INTEGER DEFAULT 5, -- Max people to connect with
  max_messages_per_day INTEGER,
  features TEXT, -- JSON array of features
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- USER SUBSCRIPTIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS user_subscriptions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  plan_id INTEGER NOT NULL REFERENCES subscription_plans(id),
  subscription_start TIMESTAMP DEFAULT NOW(),
  subscription_end TIMESTAMP,
  auto_renew BOOLEAN DEFAULT TRUE,
  payment_id VARCHAR(255),
  status VARCHAR(50) DEFAULT 'active', -- 'active', 'expired', 'cancelled'
  created_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_status (status),
  INDEX idx_subscription_end (subscription_end)
);

-- ============================================================================
-- RESUME UPDATES - Add file_url column if not exists
-- ============================================================================
ALTER TABLE resumes ADD COLUMN IF NOT EXISTS file_url VARCHAR(500);
ALTER TABLE resumes ADD COLUMN IF NOT EXISTS file_type VARCHAR(50);

-- ============================================================================
-- USERS UPDATES - Add profile image URL if not exists
-- ============================================================================
ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_image_url VARCHAR(500);
ALTER TABLE users ADD COLUMN IF NOT EXISTS company VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- ============================================================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_company ON users(company);
CREATE INDEX IF NOT EXISTS idx_users_created ON users(created_at);

-- ============================================================================
-- INSERT DEFAULT SUBSCRIPTION PLANS
-- ============================================================================
INSERT INTO subscription_plans (name, price, duration_days, max_connections, max_messages_per_day, features, is_active)
VALUES 
  ('free', 0, NULL, 5, 50, '["Basic messaging", "5 connections", "Profile view", "Resume upload"]', TRUE),
  ('premium', 99, 30, 50, 500, '["Unlimited messaging", "50 connections", "Advanced search", "Priority support"]', TRUE),
  ('pro', 299, 30, NULL, NULL, '["Unlimited everything", "All features", "24/7 support", "Custom branding"]', TRUE)
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- SCRIPT COMPLETE
-- ============================================================================
-- All tables created successfully
-- Next steps:
-- 1. Verify all tables in PostgreSQL
-- 2. Update backend routes to use these tables
-- 3. Update frontend to display data from these tables
-- 4. Configure SendPulse API credentials in .env
-- ============================================================================
