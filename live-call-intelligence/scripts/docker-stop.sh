#!/bin/bash
echo "🛑 Stopping Call Intelligence Docker Services..."
cd "$(dirname "$0")/.."
docker-compose -f docker-compose.dev.yml down
echo "✅ All services stopped!"
