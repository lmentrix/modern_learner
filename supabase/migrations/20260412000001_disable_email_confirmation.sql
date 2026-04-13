-- Fix: Allow login without email confirmation
-- Run this in Supabase SQL Editor to disable email confirmation requirement

-- Disable email confirmation for new signups
ALTER DATABASE postgres SET "auth"."enable_email_confirmation" = false;

-- Or use the Supabase Dashboard:
-- Go to Authentication -> Settings -> Email Auth
-- Uncheck "Enable email confirmations"

-- Additionally, to fix existing unconfirmed users, you can manually confirm them:
-- UPDATE auth.users
-- SET email_confirmed_at = NOW(), confirmed_at = NOW()
-- WHERE email_confirmed_at IS NULL;
