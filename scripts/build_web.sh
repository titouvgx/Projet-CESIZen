#!/bin/bash
# Compile l'application Flutter Web avec les variables d'environnement injectées via --dart-define.
# Usage : source .env && ./scripts/build_web.sh
# Le build de sortie est dans cesizen/build/web/
set -e

cd "$(dirname "$0")/../cesizen"

flutter build web \
  --base-href "/" \
  --dart-define=SUPABASE_URL=${SUPABASE_URL} \
  --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
