#!/bin/bash

# Configuration
SOURCE_URL="postgresql://postgres:asZWoBbFJehsepqPjzZzOkVPQoLfeZNo@caboose.proxy.rlwy.net:53536/railway"
TARGET_URL="postgresql://neondb_owner:npg_5JgZ7QGrPLAx@ep-twilight-cherry-aip86ui8-pooler.c-4.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"

echo "🚀 Starting Database Migration: Railway -> Neon (via Docker for version compatibility)..."

# Use Docker to run pg_dump 17 to match your source server
docker run --rm \
  -e SOURCE_URL="$SOURCE_URL" \
  -e TARGET_URL="$TARGET_URL" \
  postgres:17-alpine \
  sh -c 'pg_dump "$SOURCE_URL" | psql "$TARGET_URL"'

if [ $? -eq 0 ]; then
    echo "✅ Migration complete!"
    echo "🧪 Verifying user count..."
    docker run --rm \
      -e TARGET_URL="$TARGET_URL" \
      postgres:17-alpine \
      psql "$TARGET_URL" -c "SELECT count(*) as user_count FROM \"Users\";"
else
    echo "❌ Migration failed. Check your connection strings or network."
fi
