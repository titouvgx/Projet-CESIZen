# ── Stage 1 : Build Flutter Web ──────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:3.44.0 AS builder

ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY

WORKDIR /app
COPY . .

RUN cd cesizen && flutter pub get

RUN cd cesizen && flutter build web \
    --release \
    --base-href "/" \
    --dart-define=SUPABASE_URL=${SUPABASE_URL} \
    --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}

# ── Stage 2 : Servir avec Nginx ───────────────────────────────────
FROM nginx:alpine

COPY --from=builder /app/cesizen/build/web /usr/share/nginx/html
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
