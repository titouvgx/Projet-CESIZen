#!/bin/bash
# Déploie CESIZen en production sur VPS.
# Prérequis : SUPABASE_URL et SUPABASE_ANON_KEY dans l'environnement du VPS.
# Usage : ./scripts/deploy_prod.sh
set -e

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo '❌ SUPABASE_URL et SUPABASE_ANON_KEY doivent être définis sur le VPS'
  exit 1
fi

cd "$(dirname "$0")/.."

echo '📥 Pull dernière version...'
git pull origin master

echo '🔨 Build et redémarrage...'
docker compose -f docker-compose.prod.yml up -d --build

echo '✅ Déploiement terminé'
