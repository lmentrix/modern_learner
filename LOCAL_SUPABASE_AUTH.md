# Local Supabase Auth

This app is configured to use the local Supabase CLI stack in:

```text
../local_supabase_cli
```

## Local Endpoints

```text
Project URL: http://127.0.0.1:55521
Studio:      http://127.0.0.1:55523
Mailpit:     http://127.0.0.1:55524
Database:    postgresql://postgres:postgres@127.0.0.1:55522/postgres
```

## Flutter Environment

The app reads Supabase settings from `.env`:

```text
SUPABASE_URL=http://127.0.0.1:55521
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:55522/postgres
PUBLISHABLE_KEY=sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH
```

`main.dart` initializes `supabase_flutter` from those values. The auth service
then uses the initialized local client through `core/supabase/supabase_service.dart`.
On Android emulators, `ApiConstants.supabaseUrl` rewrites loopback hosts to
`10.0.2.2`, so this same `.env` works against services running on the host.

## Commands

Run these from `../local_supabase_cli`:

```powershell
bin\supabase.exe status
bin\supabase.exe start
bin\supabase.exe stop --project-id local_supabase_cli
```

## Notes

- Email confirmation is disabled in the generated local Supabase config, so new
  email/password signups should return a session immediately.
- `AuthService` attempts to create a matching row in `profiles` after signup or
  signin. If the local database has not been migrated yet and `profiles` does
  not exist, profile bootstrap is skipped and auth still succeeds.
- Apply the app migrations to the local database before testing profile, course,
  achievements, or progress features that depend on application tables.
