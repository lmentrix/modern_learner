-- Auto-confirm every new user on signup so email confirmation is not required.
-- This trigger fires BEFORE INSERT on auth.users and sets email_confirmed_at
-- immediately, bypassing the project-level email confirmation setting.

CREATE OR REPLACE FUNCTION public.auto_confirm_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.email_confirmed_at IS NULL THEN
    NEW.email_confirmed_at = NOW();
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS auto_confirm_user_trigger ON auth.users;
CREATE TRIGGER auto_confirm_user_trigger
  BEFORE INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.auto_confirm_new_user();
