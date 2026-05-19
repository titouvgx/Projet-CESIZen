#!/bin/bash
# Lance l'application en local avec les variables d'environnement injectées via --dart-define.
# Usage : source .env && ./scripts/run_local.sh
set -e

cd "$(dirname "$0")/../cesizen"

flutter run -d chrome \
  --dart-define=SUPABASE_URL=${SUPABASE_URL} \
  --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
