#!/usr/bin/env bash
set -euo pipefail

if [ ! -d /app-migrations ]; then
  echo "No app migration directory mounted; skipping."
  exit 0
fi

shopt -s nullglob
for migration in /app-migrations/*.sql; do
  echo "Applying app migration: ${migration}"
  psql --set ON_ERROR_STOP=1 --username "${POSTGRES_USER:-postgres}" --dbname "$POSTGRES_DB" --file "$migration"
done
