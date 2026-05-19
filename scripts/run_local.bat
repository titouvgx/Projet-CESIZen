@echo off
rem Lance l'application en local avec les variables d'environnement injectées via --dart-define.
rem Usage : set SUPABASE_URL=xxx && set SUPABASE_ANON_KEY=yyy && scripts\run_local.bat

cd /d "%~dp0..\cesizen"

flutter run -d chrome ^
  --dart-define=SUPABASE_URL=%SUPABASE_URL% ^
  --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY%
