@echo off
rem Lance l'environnement de test Docker (port 8090).
rem Usage : set SUPABASE_URL=xxx && set SUPABASE_ANON_KEY=yyy && scripts\test_env.bat

cd /d "%~dp0.."

echo Lancement environnement TEST...
docker compose -f docker-compose.test.yml up -d --build

echo Environnement TEST disponible sur http://localhost:8090
