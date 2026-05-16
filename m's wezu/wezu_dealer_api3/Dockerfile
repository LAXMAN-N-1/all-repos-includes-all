# syntax=docker/dockerfile:1.7
###############################################################################
# Wezu Dealer Portal — Flutter Web
# Multi-stage build: Flutter SDK → compiled web bundle → hardened nginx runtime
###############################################################################

# Pinned to a concrete cirruslabs tag so Dart/Flutter versions don't drift
# between deploys.
ARG NGINX_VERSION=1.27-alpine

###############################################################################
# Stage 1 — base: prebuilt Flutter SDK image
###############################################################################
FROM ghcr.io/cirruslabs/flutter:3.41.6 AS flutter-base

ENV CI=true \
    PUB_CACHE=/root/.pub-cache

RUN git config --global --add safe.directory /sdks/flutter \
    && flutter config --no-analytics --no-cli-animations >/dev/null \
    && flutter --version \
    && dart --version \
    && flutter precache --web

WORKDIR /app

###############################################################################
# Stage 2 — deps: pub get layer (only re-runs when pubspec changes)
#
# Trick: pub get writes its full output to a log file and is forced to
# succeed (||true). The NEXT RUN dumps the log and only then propagates
# the original exit code. This guarantees BuildKit shows the actual
# pub-get error in the cat output of the failing layer, regardless of
# how the upstream build runner truncates stderr from failing layers.
###############################################################################
FROM flutter-base AS deps

COPY pubspec.yaml pubspec.lock ./

RUN set -x; \
    flutter pub get -v > /tmp/pubget.log 2>&1; echo $? > /tmp/pubget.exit; \
    true

RUN echo "===== flutter pub get output =====" \
    && cat /tmp/pubget.log \
    && echo "===== exit code: $(cat /tmp/pubget.exit) =====" \
    && exit "$(cat /tmp/pubget.exit)"

###############################################################################
# Stage 3 — build: compile the Flutter web bundle
###############################################################################
FROM deps AS build

# Pulled in via docker-compose / CI; defaults are production-safe.
ARG API_BASE_URL=https://api3.powerfrill.com/api/v1
ARG APP_FLAVOR=production
ARG BUILD_NUMBER=0
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG API_ROOT_URL

# Copy the rest of the source. The COPY above already cached pub-get when
# only application code changes, so this layer is just the source diff.
COPY . .

RUN set -x; \
    flutter build web \
        --release \
        --no-tree-shake-icons \
        --base-href=/ \
        --dart-define=API_BASE_URL="${API_BASE_URL}" \
        --dart-define=API_ROOT_URL="${API_ROOT_URL}" \
        --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
        --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}" \
        --dart-define=APP_FLAVOR="${APP_FLAVOR}" \
        --dart-define=BUILD_NUMBER="${BUILD_NUMBER}" \
        > /tmp/build.log 2>&1; echo $? > /tmp/build.exit; \
    true

RUN echo "===== flutter build web output =====" \
    && cat /tmp/build.log \
    && echo "===== exit code: $(cat /tmp/build.exit) =====" \
    && exit "$(cat /tmp/build.exit)"

RUN test -d build/web && ls -la build/web

###############################################################################
# Stage 4 — runtime: distroless-ish nginx serving the static bundle
###############################################################################
FROM nginx:${NGINX_VERSION} AS runtime

# OCI metadata
LABEL org.opencontainers.image.title="wezu-dealer-portal" \
      org.opencontainers.image.description="Wezu Dealer Portal — Flutter Web" \
      org.opencontainers.image.vendor="Wezu Tech" \
      org.opencontainers.image.source="https://github.com/wezu/wezu_dealer_portal" \
      org.opencontainers.image.licenses="Proprietary"

# Drop default config and copy our hardened one
RUN rm -rf /etc/nginx/conf.d/default.conf /usr/share/nginx/html/*
COPY deploy/nginx/nginx.conf /etc/nginx/nginx.conf
COPY deploy/nginx/default.conf /etc/nginx/conf.d/default.conf

# Static bundle
COPY --from=build /app/build/web /usr/share/nginx/html

# Run nginx as the unprivileged "nginx" user that the base image already provides
RUN chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/log/nginx \
    && touch /var/run/nginx.pid \
    && chown nginx:nginx /var/run/nginx.pid

USER nginx

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1

STOPSIGNAL SIGQUIT
CMD ["nginx", "-g", "daemon off;"]
