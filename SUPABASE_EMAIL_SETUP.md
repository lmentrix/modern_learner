# Supabase Email Confirmation Setup Guide

This guide explains how to configure Supabase to enable email confirmation links that work with the ModernLearner Flutter app.

## Problem

Users couldn't click/activate the email confirmation link because:
1. Deep linking wasn't configured in the Flutter app
2. Supabase needs the correct Site URL and Redirect URLs configured

## Solution Implemented

### 1. Deep Link Configuration (Already Done)

The app now supports deep linking with the scheme `modernlearner://`:
- **iOS**: Configured in `ios/Runner/Info.plist`
- **Android**: Configured in `android/app/src/main/AndroidManifest.xml`
- **Router**: Added `/email-confirm-link` route to handle verification tokens

### 2. Supabase Dashboard Configuration (Required)

You need to configure your Supabase project with the following settings:

#### Step 1: Go to Supabase Dashboard

1. Visit https://supabase.com/dashboard
2. Select your project: `yaklkzhrueetfwidykac`
3. Go to **Authentication** → **URL Configuration**

#### Step 2: Configure Site URL

Set the **Site URL** to your app's deep link scheme:

```
modernlearner://email-confirm-link
```

#### Step 3: Configure Redirect URLs

Add the following to **Redirect URLs**:

```
modernlearner://email-confirm-link
modernlearner://
```

For development with web/browser testing, also add:
```
http://localhost:3000
http://localhost:8080
```

#### Step 4: Enable Email Confirmations

1. Go to **Authentication** → **Providers**
2. Ensure **Email** is enabled
3. Make sure **Confirm email** is toggled ON

#### Step 5: Customize Email Template (Optional)

1. Go to **Authentication** → **Email Templates**
2. Select **Confirm signup**
3. Ensure the confirmation link uses the correct URL format:

```html
<a href="{{ .ConfirmationURL }}">Confirm your email</a>
```

The `{{ .ConfirmationURL }}` will automatically include the token and type parameters.

### 3. Testing the Setup

#### On iOS Simulator/Device:

1. Run the app: `flutter run`
2. Register with a test email
3. Check your email inbox
4. Click the confirmation link
5. The app should open and automatically verify your email

#### On Android Emulator/Device:

1. Run the app: `flutter run`
2. Register with a test email
3. Check your email inbox
4. Click the confirmation link
5. The app should open and automatically verify your email

#### Testing Deep Links Manually:

**iOS Simulator:**
```bash
xcrun simctl openurl booted "modernlearner://email-confirm-link?token=TEST_TOKEN&type=signup"
```

**Android Emulator:**
```bash
adb shell am start -W -a android.intent.action.VIEW \
  -d "modernlearner://email-confirm-link?token=TEST_TOKEN&type=signup" \
  com.example.modern_learner_production
```

### 4. Environment Variables

Make sure your `.env` file contains:

```env
SUPABASE_URL=https://yaklkzhrueetfwidykac.supabase.co
PUBLISHABLE_KEY=your-supabase-anon-key
```

To find your credentials:
1. Go to Supabase Dashboard → **Settings** → **API**
2. Copy the **Project URL** and **anon/public** key

### 5. Troubleshooting

#### Email not sending
- Check Supabase logs in Dashboard → **Logs**
- Verify SMTP is configured (Supabase handles this by default)

#### Link doesn't open app
- Verify deep link scheme is correctly configured in both iOS and Android
- On Android, ensure the app is installed (deep links don't work for uninstalled apps)
- On iOS, try long-pressing the link and selecting "Open in [Your App]"

#### Verification fails
- Check that the token hasn't expired (default: 24 hours)
- Ensure the token type matches (`signup` for new registrations)
- Check Supabase logs for error details

#### Link opens browser instead of app
- This is expected behavior on some devices
- The browser will show an error since the route doesn't exist on web
- Consider implementing a web fallback page in Supabase hosting

## Architecture

```
User Registration Flow:
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌──────────────┐
│   User      │────▶│  Register    │────▶│  Supabase   │────▶│  Email Sent  │
│   Signs Up  │     │  Page        │     │  Auth       │     │  to User     │
└─────────────┘     └──────────────┘     └─────────────┘     └──────────────┘

Email Confirmation Flow:
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌──────────────┐
│   User      │────▶│  Deep Link   │────▶│  App Opens  │────▶│  Automatic   │
│  Clicks     │     │  Triggered   │     │  to Route   │     │  Verification│
│  Email Link │     │              │     │              │     │              │
└─────────────┘     └──────────────┘     └─────────────┘     └──────────────┘
```

## Files Modified

1. `ios/Runner/Info.plist` - Added CFBundleURLTypes for iOS deep linking
2. `android/app/src/main/AndroidManifest.xml` - Added intent-filter for Android deep linking
3. `lib/app/app_router.dart` - Added `/email-confirm-link` route
4. `lib/features/auth/presentation/pages/email_confirmation_page.dart` - Added automatic verification logic
5. `lib/core/theme/app_colors.dart` - Added missing color constants

## Next Steps

1. **Configure Supabase Dashboard** as described above
2. **Test** the email confirmation flow end-to-end
3. **Update** the `.env` file with your Supabase credentials
4. **Deploy** to test devices and verify deep linking works
