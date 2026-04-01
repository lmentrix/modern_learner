# Email Confirmation Implementation with Resend + Supabase

This document describes the complete implementation of custom email confirmation using Resend for email delivery and Supabase for authentication.

## Overview

The implementation combines:
- **Supabase Auth**: User authentication and session management
- **Resend**: Custom-branded transactional emails
- **Supabase Edge Functions**: Bridge between Supabase and Resend
- **Flutter App**: Deep link handling for email confirmation

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Flutter App    │────▶│  Supabase Auth   │────▶│  Edge Function  │
│  (Sign Up)      │     │  (Create User)   │     │  (Send Email)   │
└─────────────────┘     └──────────────────┘     └─────────────────┘
         │                                              │
         │                                              ▼
         │                                     ┌─────────────────┐
         │                                     │     Resend      │
         │                                     │  (Send Email)   │
         │                                     └─────────────────┘
         │                                              │
         ▼                                              ▼
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Deep Link      │◀────│  User Clicks     │◀────│  User Receives  │
│  Handling       │     │  Confirmation    │     │  Custom Email   │
└─────────────────┘     └──────────────────┘     └──────────────────┘
```

## Files Created/Modified

### Backend (Supabase + Resend)

| File | Purpose |
|------|---------|
| `supabase/functions/send-email/index.ts` | Edge Function that sends emails via Resend |
| `supabase/functions/send-email/import_map.json` | Deno import mappings |
| `supabase/migrations/20260401000000_setup_email_confirmation.sql` | Database schema for tracking confirmations |
| `supabase/DEPLOYMENT.md` | Deployment instructions |

### Frontend (Flutter)

| File | Changes |
|------|---------|
| `lib/features/auth/data/datasources/auth_remote_data_source.dart` | Added `sendConfirmationEmail()` and Edge Function integration |
| `lib/features/auth/presentation/pages/email_confirmation_page.dart` | Added deep link handling and automatic verification |
| `lib/app/app_router.dart` | Added `/email-confirm-link` route for deep links |
| `ios/Runner/Info.plist` | Added `CFBundleURLTypes` for iOS deep linking |
| `android/app/src/main/AndroidManifest.xml` | Added intent-filter for Android deep linking |
| `lib/main.dart` | Configured Supabase auth flow type |
| `lib/core/theme/app_colors.dart` | Added missing color constants |

### Configuration

| File | Changes |
|------|---------|
| `.mcp.json` | Added Resend MCP server |
| `.env` | Added `RESEND_API_KEY` and `FROM_EMAIL` |
| `.env.example` | Added Resend environment variables template |

## Email Template Features

The custom email template includes:
- **Modern Design**: Dark theme matching the app's visual identity
- **Branded Header**: Gradient background with welcome message
- **Clear CTA**: Prominent "Confirm Email Address" button
- **Fallback Link**: Copy-paste URL for unsupported clients
- **Mobile Tips**: Instructions for mobile app users
- **Security Notice**: Expiration time and safety information
- **Professional Footer**: Copyright and branding

## How It Works

### 1. User Registration

```dart
// In auth_remote_data_source.dart
final response = await _supabase.auth.signUp(
  email: email,
  password: password,
  data: {'name': name},
);

if (response.session == null) {
  // Email confirmation required
  await _sendCustomConfirmationEmail(email);
  throw EmailConfirmationRequiredException(email: email);
}
```

### 2. Custom Email Sending

```typescript
// In supabase/functions/send-email/index.ts
const resend = new Resend(Deno.env.get("RESEND_API_KEY"));

await resend.emails.send({
  from: Deno.env.get("FROM_EMAIL"),
  to: email,
  subject: "Confirm your email - ModernLearner",
  html: customEmailTemplate,
});
```

### 3. Deep Link Handling

```dart
// In app_router.dart
GoRoute(
  path: '/email-confirm-link',
  builder: (context, state) {
    final token = state.uri.queryParameters['token'];
    final type = state.uri.queryParameters['type'];
    return EmailConfirmationPage(
      email: '',
      confirmationToken: token,
      confirmationType: type,
      redirectPath: redirect,
    );
  },
),
```

### 4. Automatic Verification

```dart
// In email_confirmation_page.dart
@override
void initState() {
  super.initState();
  if (widget.confirmationToken != null && widget.confirmationType != null) {
    _verifyEmail();
  }
}

Future<void> _verifyEmail() async {
  await Supabase.instance.client.auth.getSessionFromUrl(
    Uri.parse('modernlearner://email-confirm-link?token=...&type=...'),
  );
  // Redirect to home on success
}
```

## Deployment Steps

### 1. Install Supabase CLI

```bash
npm install -g supabase
# or
brew install supabase/tap/supabase
```

### 2. Login and Link Project

```bash
supabase login
supabase link --project-ref yaklkzhrueetfwidykac
```

### 3. Set Environment Variables

```bash
supabase secrets set RESEND_API_KEY=re_c8s5pdx6_2AaxegP7rGVNDJ6WP1vJqFyY
supabase secrets set FROM_EMAIL=noreply@yourdomain.com
supabase secrets set SITE_URL=modernlearner://email-confirm-link
```

### 4. Deploy Edge Function

```bash
supabase functions deploy send-email
```

### 5. Run Database Migration

```bash
supabase db push
```

### 6. Configure Supabase Dashboard

1. Go to **Authentication** → **URL Configuration**
2. Set **Site URL**: `modernlearner://email-confirm-link`
3. Add to **Redirect URLs**:
   - `modernlearner://email-confirm-link`
   - `modernlearner://`

### 7. Update Resend Settings

1. Go to https://resend.com
2. Verify your domain (or use `onboarding@resend.dev` for testing)
3. Update `FROM_EMAIL` in Supabase secrets

## Testing

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

1. Run the Flutter app on a device/simulator
2. Register with a test email
3. Check email inbox for custom-branded confirmation
4. Click the confirmation link
5. Verify the app opens and confirms automatically

### Test Deep Links Manually

**iOS:**
```bash
xcrun simctl openurl booted "modernlearner://email-confirm-link?token=TEST&type=signup"
```

**Android:**
```bash
adb shell am start -W -a android.intent.action.VIEW \
  -d "modernlearner://email-confirm-link?token=TEST&type=signup" \
  com.example.modern_learner_production
```

## Resend MCP Server Usage

The Resend MCP server is configured in `.mcp.json` for AI assistant access:

```json
{
  "mcpServers": {
    "resend": {
      "command": "npx",
      "args": ["-y", "resend-mcp"],
      "env": {
        "RESEND_API_KEY": "re_c8s5pdx6_2AaxegP7rGVNDJ6WP1vJqFyY"
      }
    }
  }
}
```

This allows the AI assistant to:
- Check email delivery status
- View email logs
- Manage Resend resources
- Debug email issues

## Troubleshooting

### Email Not Sending

1. Check Edge Function logs in Supabase Dashboard → **Logs**
2. Verify `RESEND_API_KEY` is correct
3. Ensure `FROM_EMAIL` domain is verified in Resend
4. Check Resend dashboard at https://resend.com

### Deep Link Not Working

1. Verify URL scheme in `Info.plist` and `AndroidManifest.xml`
2. Check Supabase Dashboard URL configuration
3. Test with manual deep link commands (see above)
4. See `SUPABASE_EMAIL_SETUP.md` for detailed setup

### Edge Function Errors

1. Check function logs: `supabase functions logs send-email`
2. Verify all secrets are set: `supabase secrets list`
3. Test function locally: `supabase functions serve send-email`

## Security Considerations

- **Token Expiration**: Confirmation tokens expire after 24 hours
- **Rate Limiting**: Implement rate limiting for resend requests
- **API Key Security**: Never expose `RESEND_API_KEY` in client code
- **Service Role Key**: Keep `SERVICE_ROLE_KEY` secure, use only in Edge Functions

## Future Enhancements

1. **Email Analytics**: Track open rates and click-through rates
2. **Localized Emails**: Support multiple languages
3. **Email Preferences**: Allow users to choose email frequency
4. **Backup Provider**: Add secondary email provider for redundancy
5. **Email Queue**: Implement queue for high-volume sending

## References

- [Supabase Edge Functions Docs](https://supabase.com/docs/guides/functions)
- [Resend Documentation](https://resend.com/docs)
- [Supabase Auth Email](https://supabase.com/docs/guides/auth/auth-email)
- [Flutter Deep Linking](https://docs.flutter.dev/ui/navigation/deep-linking)
