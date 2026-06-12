# Local Supabase with Docker Compose

This directory contains the official Supabase self-hosted Docker Compose bundle, adapted for the
Modern Learner local development ports and migrations.

## Start

```powershell
cd supabase/docker
docker compose up -d
```

## Stop

```powershell
cd supabase/docker
docker compose down
```

## Local endpoints

- Supabase API and Studio: `http://127.0.0.1:55421`
- Postgres: `postgresql://postgres:modern_learner_local_postgres_password@localhost:55422/postgres`
- Transaction pooler: `localhost:55429`

Studio is protected by HTTP Basic Auth:

- Username: `supabase`
- Password: `modern_learner_local_dashboard_password`

## App environment

For the Flutter app to use this local stack, set:

```dotenv
SUPABASE_URL=http://127.0.0.1:55421
PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE
```

## Migrations and Edge Functions

On first database initialization, Compose applies SQL files from `../migrations`.
Existing Edge Functions under `../functions` are mounted read-only and take precedence over the
sample functions bundled in `volumes/functions`.

To re-run migrations from a clean database, remove the persisted database data before starting
again:

```powershell
cd supabase/docker
docker compose down -v
docker compose up -d
```
