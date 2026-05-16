#!/bin/bash
echo "🐳 Checking Docker container status..."

if ! docker info > /dev/null 2>&1; then
  echo "❌ Docker daemon not running. Please start Docker Desktop."
  exit 1
fi

echo "✅ Docker daemon is running."
containers=$(docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}")

if [ -z "$containers" ]; then
  echo "⚠️ No containers running."
else
  echo "🟢 Running containers:"
  echo "$containers"
fi
