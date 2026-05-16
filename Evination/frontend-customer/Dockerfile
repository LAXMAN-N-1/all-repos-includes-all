# Stage 1: Build Environment
FROM debian:latest AS build-env

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Clone Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Fix the flutter version to stable
RUN flutter channel stable && flutter upgrade

# Copy the app files
WORKDIR /app
COPY . .

# Build for Web
ARG API_URL=http://localhost:8000/api
RUN flutter pub get
RUN flutter build web --release --dart-define=API_URL=$API_URL

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy the build output
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy custom nginx config for SPA support
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
