#!/bin/bash
# Lance l'environnement de test Docker (port 8090).
# Usage : source .env && ./scripts/test_env.sh
set -e

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo '❌ SUPABASE_URL et SUPABASE_ANON_KEY doivent être définis'
  echo '   Exemple : source .env && ./scripts/test_env.sh'
  exit 1
fi

cd "$(dirname "$0")/.."

echo '🧪 Lancement environnement TEST...'
docker compose -f docker-compose.test.yml up -d --build

echo '⏳ Attente démarrage...'
sleep 5

docker ps | grep cesizen-test

echo '✅ Environnement TEST disponible sur http://localhost:8090'
