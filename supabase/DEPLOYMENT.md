# Supabase Edge Functions Deployment Guide

This guide explains how to deploy the Resend email confirmation Edge Function to your Supabase project.

## Prerequisites

1. Install the Supabase CLI:
   ```bash
   npm install -g supabase
   # or
   brew install supabase/tap/supabase
   ```

2. Login to Supabase:
   ```bash
   supabase login
   ```

3. Link your project:
   ```bash
   supabase link --project-ref yaklkzhrueetfwidykac
   ```

## Step 1: Set Environment Variables

Set the required secrets in your Supabase project:

```bash
# Set Resend API Key
supabase secrets set RESEND_API_KEY=re_c8s5pdx6_2AaxegP7rGVNDJ6WP1vJqFyY

# Set From Email (use your verified Resend domain)
supabase secrets set FROM_EMAIL=noreply@yourdomain.com

# Set Service Role Key (find in Supabase Dashboard > Settings > API)
supabase secrets set SERVICE_ROLE_KEY=your-service-role-key

# Set Site URL for deep links
supabase secrets set SITE_URL=modernlearner://email-confirm-link
```

## Step 2: Deploy the Edge Function

```bash
cd supabase/functions/send-email
supabase functions deploy send-email
```

## Step 3: Run Database Migrations

Apply the database migration to create the necessary tables and functions:

```bash
supabase db push
```

Or manually run the migration file in Supabase Dashboard:
1. Go to **SQL Editor**
2. Copy contents of `supabase/migrations/20260401000000_setup_email_confirmation.sql`
3. Paste and run

## Step 4: Configure Supabase Auth

### Option A: Use Supabase Dashboard (Recommended)

1. Go to **Authentication** → **Email Templates**
2. Select **Confirm signup**
3. Change the template to use a custom URL that calls your Edge Function

However, since Supabase's built-in email system doesn't directly support calling Edge Functions, we'll use a different approach:

### Option B: Handle in Application Code

Update your Flutter app to call the Edge Function after signup:

1. After calling `signUp()`, trigger the Edge Function
2. The Edge Function sends the email via Resend
3. User receives the custom-branded email

## Step 5: Test the Integration

### Test Edge Function Directly

```bash
curl -X POST 'https://yaklkzhrueetfwidykac.supabase.co/functions/v1/send-email' \
  -H 'Authorization: Bearer YOUR_SERVICE_ROLE_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "test@example.com",
    "token": "test-token-123",
    "type": "signup",
    "siteUrl": "modernlearner://email-confirm-link"
  }'
```

### Test Full Flow

1. Run your Flutter app
2. Register with a test email
3. Check if the email is received with the custom design
4. Click the confirmation link
5. Verify the app opens and confirms the email

## Troubleshooting

### Edge Function Returns 500 Error

- Check the function logs in Supabase Dashboard → **Logs**
- Verify `RESEND_API_KEY` is set correctly
- Ensure the Resend domain is verified

### Email Not Sending

- Check Resend dashboard at https://resend.com
- Verify the `FROM_EMAIL` is from a verified domain
- Check spam folder

### Deep Link Not Working

- Verify the `siteUrl` parameter matches your deep link scheme
- Check iOS `Info.plist` and Android `AndroidManifest.xml` configurations
- See `SUPABASE_EMAIL_SETUP.md` for detailed deep link setup

## Alternative: Use Supabase Hooks (Beta)

Supabase Hooks allow you to trigger Edge Functions on auth events:

1. Go to **Authentication** → **Hooks**
2. Add a new hook for `user.signup` event
3. Set the webhook URL to your Edge Function URL
4. Configure the payload to include email and token

This approach is cleaner but requires Supabase Hooks to be available in your region.

## Files Structure

```
supabase/
├── functions/
│   └── send-email/
│       ├── index.ts              # Edge Function code
│       └── import_map.json       # Deno imports
├── migrations/
│   └── 20260401000000_setup_email_confirmation.sql
└── config.toml                   # Supabase configuration
```

## Next Steps

1. Customize the email template in `send-email/index.ts`
2. Add email tracking and analytics
3. Implement email resending with rate limiting
4. Add support for other email types (password reset, etc.)
