#!/bin/bash
# Build et lance CESIZen avec Docker en local.
# Usage : source .env && ./scripts/build_docker.sh
set -e

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo '❌ SUPABASE_URL et SUPABASE_ANON_KEY doivent être définis'
  echo '   Exemple : source .env && ./scripts/build_docker.sh'
  exit 1
fi

cd "$(dirname "$0")/.."

echo '🔨 Build Docker CESIZen...'
docker compose build --no-cache

echo '🚀 Lancement...'
docker compose up -d

echo '✅ CESIZen disponible sur http://localhost:80'
