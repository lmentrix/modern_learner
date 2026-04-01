-- Migration: Setup custom email confirmation with Resend
-- Created: 2026-04-01
-- Description: Sets up database function and trigger to send confirmation emails via Resend

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create a table to store pending email confirmations
CREATE TABLE IF NOT EXISTS public.pending_email_confirmations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT NOT NULL,
    token TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'signup',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '24 hours'),
    sent_at TIMESTAMPTZ,
    confirmed_at TIMESTAMPTZ
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_pending_email_confirmations_email ON public.pending_email_confirmations(email);
CREATE INDEX IF NOT EXISTS idx_pending_email_confirmations_token ON public.pending_email_confirmations(token);
CREATE INDEX IF NOT EXISTS idx_pending_email_confirmations_expires_at ON public.pending_email_confirmations(expires_at);

-- Create function to send confirmation email via Edge Function
CREATE OR REPLACE FUNCTION public.send_confirmation_email(
    p_email TEXT,
    p_token TEXT,
    p_type TEXT DEFAULT 'signup'
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_response JSON;
    v_edge_function_url TEXT;
    v_service_role_key TEXT;
    v_site_url TEXT;
BEGIN
    -- Get the Edge Function URL from config or use default
    v_edge_function_url := current_setting('app.settings.edge_function_url', TRUE) 
        OR 'https://yaklkzhrueetfwidykac.supabase.co/functions/v1/send-email';
    
    -- Get the service role key for authentication
    v_service_role_key := current_setting('app.settings.service_role_key', TRUE);
    
    -- Get the site URL for the confirmation link
    v_site_url := current_setting('app.settings.site_url', TRUE) 
        OR 'modernlearner://email-confirm-link';
    
    -- Call the Edge Function using pg_net or http extension
    -- Note: This requires the pg_net extension to be enabled
    BEGIN
        -- Insert the pending confirmation record
        INSERT INTO public.pending_email_confirmations (email, token, type)
        VALUES (p_email, p_token, p_type);
        
        -- Make HTTP request to Edge Function
        -- This uses the net.http_post function from pg_net extension
        SELECT INTO v_response response_body
        FROM net.http_post(
            url := v_edge_function_url,
            headers := JSONB_BUILD_OBJECT(
                'Content-Type', 'application/json',
                'Authorization', 'Bearer ' || v_service_role_key
            ),
            body := JSONB_BUILD_OBJECT(
                'email', p_email,
                'token', p_token,
                'type', p_type,
                'siteUrl', v_site_url
            )
        ) AS response_body;
        
        -- Update the sent_at timestamp
        UPDATE public.pending_email_confirmations
        SET sent_at = NOW()
        WHERE email = p_email AND token = p_token;
        
        RETURN JSONB_BUILD_OBJECT(
            'success', true,
            'message', 'Confirmation email sent'
        );
    EXCEPTION
        WHEN OTHERS THEN
            RETURN JSONB_BUILD_OBJECT(
                'success', false,
                'error', SQLERRM
            );
    END;
END;
$$;

-- Grant permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT EXECUTE ON FUNCTION public.send_confirmation_email TO authenticated;
GRANT ALL ON TABLE public.pending_email_confirmations TO authenticated;

-- Enable Row Level Security
ALTER TABLE public.pending_email_confirmations ENABLE ROW LEVEL SECURITY;

-- Create policies for pending_email_confirmations table
CREATE POLICY "Users can view their own pending confirmations"
    ON public.pending_email_confirmations
    FOR SELECT
    USING (auth.jwt() ->> 'email' = email);

CREATE POLICY "Service role can manage all confirmations"
    ON public.pending_email_confirmations
    FOR ALL
    USING (true);

-- Comment describing the migration
COMMENT ON TABLE public.pending_email_confirmations IS 
    'Stores pending email confirmation requests for tracking and resending';

COMMENT ON FUNCTION public.send_confirmation_email IS 
    'Sends a confirmation email via Resend Edge Function';
