-- Row Level Security (RLS) Policies for Supabase
-- Run this SQL in your Supabase SQL Editor after running supabase_schema.sql

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.approval_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_activity ENABLE ROW LEVEL SECURITY;

-- Helper function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function to check if user is teacher
CREATE OR REPLACE FUNCTION is_teacher()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'teacher'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Users table policies
CREATE POLICY "Users can view their own profile"
  ON public.users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
  ON public.users FOR SELECT
  USING (is_admin());

CREATE POLICY "Users can update their own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Admins can update any profile"
  ON public.users FOR UPDATE
  USING (is_admin());

CREATE POLICY "Users can insert their own profile"
  ON public.users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Notices table policies
CREATE POLICY "Anyone authenticated can view active notices"
  ON public.notices FOR SELECT
  USING (auth.uid() IS NOT NULL AND is_active = true);

CREATE POLICY "Teachers and admins can create notices"
  ON public.notices FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL AND (is_teacher() OR is_admin()));

CREATE POLICY "Authors and admins can update their notices"
  ON public.notices FOR UPDATE
  USING (auth.uid() = author_id OR is_admin());

CREATE POLICY "Authors and admins can delete their notices"
  ON public.notices FOR DELETE
  USING (auth.uid() = author_id OR is_admin());

-- Messages table policies
CREATE POLICY "Users can view their own messages"
  ON public.messages FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = recipient_id);

CREATE POLICY "Admins can view all messages"
  ON public.messages FOR SELECT
  USING (is_admin());

CREATE POLICY "Users can send messages"
  ON public.messages FOR INSERT
  WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Recipients can update message read status"
  ON public.messages FOR UPDATE
  USING (auth.uid() = recipient_id);

CREATE POLICY "Admins can delete messages"
  ON public.messages FOR DELETE
  USING (is_admin());

-- Notifications table policies
CREATE POLICY "Users can view their own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can create notifications"
  ON public.notifications FOR INSERT
  WITH CHECK (is_admin());

-- Approval requests table policies
CREATE POLICY "Users can view their own approval requests"
  ON public.approval_requests FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all approval requests"
  ON public.approval_requests FOR SELECT
  USING (is_admin());

CREATE POLICY "Users can create approval requests"
  ON public.approval_requests FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users and admins can update approval requests"
  ON public.approval_requests FOR UPDATE
  USING (auth.uid() = user_id OR is_admin());

-- User activity table policies
CREATE POLICY "Users can create their own activity logs"
  ON public.user_activity FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all activity logs"
  ON public.user_activity FOR SELECT
  USING (is_admin());
