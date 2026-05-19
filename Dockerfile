# ── Stage 1 : Build Flutter Web ──────────────────────────────────
FROM debian:bookworm-slim AS builder

ARG FLUTTER_VERSION=3.41.1
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$FLUTTER_HOME/bin:$PATH

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git \
    --depth 1 \
    --branch $FLUTTER_VERSION \
    $FLUTTER_HOME

RUN flutter config --enable-web
RUN flutter precache --web

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
