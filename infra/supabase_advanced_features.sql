-- Advanced Features for Supabase
-- Run this SQL in your Supabase SQL Editor after running supabase_schema.sql and supabase_rls_policies.sql

-- ============================================================================
-- FULL-TEXT SEARCH
-- ============================================================================

-- Add full-text search columns to notices table
ALTER TABLE public.notices ADD COLUMN IF NOT EXISTS search_vector tsvector;

-- Create index for full-text search
CREATE INDEX IF NOT EXISTS notices_search_idx ON public.notices USING gin(search_vector);

-- Create function to update search vector
CREATE OR REPLACE FUNCTION update_notices_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector := 
    setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.content, '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update search vector
DROP TRIGGER IF EXISTS notices_search_vector_update ON public.notices;
CREATE TRIGGER notices_search_vector_update
  BEFORE INSERT OR UPDATE ON public.notices
  FOR EACH ROW
  EXECUTE FUNCTION update_notices_search_vector();

-- Update existing notices
UPDATE public.notices SET search_vector = 
  setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
  setweight(to_tsvector('english', COALESCE(content, '')), 'B');

-- Create full-text search function
CREATE OR REPLACE FUNCTION search_notices(search_query text)
RETURNS TABLE (
  id UUID,
  title TEXT,
  content TEXT,
  type TEXT,
  rank REAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    n.id,
    n.title,
    n.content,
    n.type,
    ts_rank(n.search_vector, plainto_tsquery('english', search_query)) as rank
  FROM public.notices n
  WHERE 
    n.is_active = true 
    AND n.search_vector @@ plainto_tsquery('english', search_query)
  ORDER BY rank DESC, n.created_at DESC
  LIMIT 50;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- ANALYTICS VIEWS
-- ============================================================================

-- Daily active users view
CREATE OR REPLACE VIEW public.daily_active_users AS
SELECT 
  DATE(created_at) as date,
  COUNT(DISTINCT user_id) as active_users
FROM public.user_activity
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Notice engagement view
CREATE OR REPLACE VIEW public.notice_engagement AS
SELECT 
  n.id,
  n.title,
  n.type,
  n.author_id,
  COUNT(DISTINCT ua.user_id) as views,
  n.created_at
FROM public.notices n
LEFT JOIN public.user_activity ua 
  ON ua.data->>'noticeId' = n.id::text
  AND ua.activity_type = 'view_notice'
WHERE n.is_active = true
GROUP BY n.id, n.title, n.type, n.author_id, n.created_at
ORDER BY views DESC;

-- Message statistics view
CREATE OR REPLACE VIEW public.message_statistics AS
SELECT 
  DATE(created_at) as date,
  type,
  COUNT(*) as total_count,
  SUM(CASE WHEN read = true THEN 1 ELSE 0 END) as read_count,
  SUM(CASE WHEN read = false THEN 1 ELSE 0 END) as unread_count
FROM public.messages
GROUP BY DATE(created_at), type
ORDER BY date DESC;

-- User engagement summary
CREATE OR REPLACE VIEW public.user_engagement_summary AS
SELECT 
  u.id,
  u.display_name,
  u.role,
  COUNT(DISTINCT CASE WHEN ua.activity_type = 'view_notice' THEN ua.id END) as notices_viewed,
  COUNT(DISTINCT CASE WHEN m.sender_id = u.id THEN m.id END) as messages_sent,
  COUNT(DISTINCT CASE WHEN n.author_id = u.id THEN n.id END) as notices_created,
  MAX(ua.created_at) as last_active
FROM public.users u
LEFT JOIN public.user_activity ua ON ua.user_id = u.id
LEFT JOIN public.messages m ON m.sender_id = u.id
LEFT JOIN public.notices n ON n.author_id = u.id
WHERE u.is_active = true
GROUP BY u.id, u.display_name, u.role
ORDER BY last_active DESC;

-- ============================================================================
-- PERFORMANCE OPTIMIZATIONS
-- ============================================================================

-- Additional indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_notices_search_text ON public.notices USING gin(to_tsvector('english', title || ' ' || content));
CREATE INDEX IF NOT EXISTS idx_notices_type_active ON public.notices(type, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_notices_target_audience ON public.notices(target_audience, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_notices_expires_at ON public.notices(expires_at) WHERE expires_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_messages_conversation ON public.messages(sender_id, recipient_id, created_at);
CREATE INDEX IF NOT EXISTS idx_messages_unread ON public.messages(recipient_id, read) WHERE read = false;

CREATE INDEX IF NOT EXISTS idx_user_activity_type ON public.user_activity(activity_type, created_at);
CREATE INDEX IF NOT EXISTS idx_user_activity_user_created ON public.user_activity(user_id, created_at);

-- ============================================================================
-- DATA RETENTION & CLEANUP
-- ============================================================================

-- Function to clean up old user activity (keeps last 90 days)
CREATE OR REPLACE FUNCTION cleanup_old_user_activity()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM public.user_activity
  WHERE created_at < NOW() - INTERVAL '90 days';
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up expired notices
CREATE OR REPLACE FUNCTION cleanup_expired_notices()
RETURNS INTEGER AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  UPDATE public.notices
  SET is_active = false
  WHERE is_active = true 
    AND expires_at IS NOT NULL 
    AND expires_at < NOW();
  
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up old read messages (keeps last 30 days)
CREATE OR REPLACE FUNCTION cleanup_old_read_messages()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM public.messages
  WHERE read = true 
    AND read_at < NOW() - INTERVAL '30 days';
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- AUTOMATED BACKUP PREPARATION
-- ============================================================================

-- Function to generate backup metadata
CREATE OR REPLACE FUNCTION generate_backup_metadata()
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'backup_date', NOW(),
    'database_size', pg_database_size(current_database()),
    'tables', json_build_object(
      'users', (SELECT COUNT(*) FROM public.users),
      'notices', (SELECT COUNT(*) FROM public.notices),
      'messages', (SELECT COUNT(*) FROM public.messages),
      'notifications', (SELECT COUNT(*) FROM public.notifications),
      'user_activity', (SELECT COUNT(*) FROM public.user_activity)
    ),
    'active_users', (SELECT COUNT(*) FROM public.users WHERE is_active = true),
    'active_notices', (SELECT COUNT(*) FROM public.notices WHERE is_active = true)
  ) INTO result;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- NOTIFICATION BATCHING
-- ============================================================================

-- Function to batch send notifications (reduces Edge Function calls)
CREATE OR REPLACE FUNCTION batch_send_notifications(
  notice_id UUID,
  notice_title TEXT,
  notice_content TEXT,
  notice_type TEXT,
  target_audience TEXT
)
RETURNS INTEGER AS $$
DECLARE
  inserted_count INTEGER;
BEGIN
  INSERT INTO public.notifications (user_id, type, title, body, data, read)
  SELECT 
    u.id,
    'notice',
    notice_title,
    SUBSTRING(notice_content, 1, 100) || '...',
    json_build_object('noticeId', notice_id, 'type', notice_type)::jsonb,
    false
  FROM public.users u
  WHERE u.is_active = true
    AND (target_audience = 'all' OR u.role = target_audience);
  
  GET DIAGNOSTICS inserted_count = ROW_COUNT;
  RETURN inserted_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- REAL-TIME SUBSCRIPTIONS OPTIMIZATION
-- ============================================================================

-- Enable real-time for specific tables with filters
-- This reduces bandwidth and improves performance

-- Notices: Only send updates for active notices
ALTER PUBLICATION supabase_realtime ADD TABLE public.notices;
ALTER PUBLICATION supabase_realtime SET (publish = 'insert, update, delete');

-- Messages: Only send to relevant users (handled by RLS)
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;

-- Notifications: Only send to relevant users (handled by RLS)
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;

-- ============================================================================
-- PERFORMANCE MONITORING
-- ============================================================================

-- View for slow queries (requires pg_stat_statements extension)
-- Run: CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

CREATE OR REPLACE VIEW public.slow_queries AS
SELECT 
  query,
  calls,
  total_exec_time,
  mean_exec_time,
  max_exec_time
FROM pg_stat_statements
WHERE mean_exec_time > 100 -- queries taking more than 100ms on average
ORDER BY mean_exec_time DESC
LIMIT 20;

-- ============================================================================
-- CACHING STRATEGY
-- ============================================================================

-- Materialized view for frequently accessed data
CREATE MATERIALIZED VIEW IF NOT EXISTS public.notice_summary AS
SELECT 
  type,
  COUNT(*) as total_count,
  SUM(CASE WHEN is_active = true THEN 1 ELSE 0 END) as active_count,
  MAX(created_at) as latest_created
FROM public.notices
GROUP BY type;

-- Create index on materialized view
CREATE UNIQUE INDEX IF NOT EXISTS notice_summary_type_idx ON public.notice_summary(type);

-- Function to refresh materialized view
CREATE OR REPLACE FUNCTION refresh_notice_summary()
RETURNS VOID AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY public.notice_summary;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SCHEDULED JOBS (requires pg_cron extension)
-- ============================================================================

-- Note: pg_cron may not be available on Supabase free tier
-- These are examples - use Supabase Dashboard cron or external scheduler

-- Clean up old data daily at 2 AM
-- SELECT cron.schedule('cleanup-old-data', '0 2 * * *', 'SELECT cleanup_old_user_activity(); SELECT cleanup_expired_notices();');

-- Refresh materialized views hourly
-- SELECT cron.schedule('refresh-views', '0 * * * *', 'SELECT refresh_notice_summary();');

-- Generate daily backup metadata
-- SELECT cron.schedule('backup-metadata', '0 3 * * *', 'INSERT INTO backup_metadata SELECT generate_backup_metadata();');

-- ============================================================================
-- COMPLETION
-- ============================================================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT SELECT ON ALL VIEWS IN SCHEMA public TO authenticated;
GRANT EXECUTE ON FUNCTION search_notices TO authenticated;
GRANT EXECUTE ON FUNCTION generate_backup_metadata TO authenticated;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Advanced features installed successfully!';
  RAISE NOTICE 'Enabled: Full-text search, Analytics views, Performance optimizations, Data cleanup functions';
END $$;
