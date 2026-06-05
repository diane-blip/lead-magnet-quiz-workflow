-- Cloudflare D1 analytics schema (SRC adaptation).
-- This is the ONLY database in the adapted stack. Leads live in Kit, not here.
-- Replaces the original Supabase schema.sql (leads / quiz_responses / email_queue /
-- content_blocks / analytics_events). Only analytics_events survives.

CREATE TABLE IF NOT EXISTS analytics_events (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  -- one of: page_view, quiz_start, question_viewed, answer_selected,
  --         email_captured, quiz_completed, result_page_viewed, cta_clicked
  event_type    TEXT NOT NULL,
  profile_id    TEXT,            -- result profile, when known
  temperature   TEXT,            -- hot | warm | cold (internal only)
  question_id   TEXT,            -- for question_viewed / answer_selected
  answer_id     TEXT,            -- for answer_selected
  utm_source    TEXT,
  created_at    TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_events_type    ON analytics_events (event_type);
CREATE INDEX IF NOT EXISTS idx_events_created ON analytics_events (created_at);
CREATE INDEX IF NOT EXISTS idx_events_profile ON analytics_events (profile_id);

-- Notes:
-- * No PII stored here. Email + quiz answers live on the Kit subscriber record.
-- * The dashboard's answer-analysis charts read from answer_selected rows.
-- * Nightly cron deletes rows older than DATA_RETENTION_ANALYTICS_DAYS (default 90).
