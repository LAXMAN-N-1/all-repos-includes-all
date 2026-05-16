#!/bin/bash
echo "🚀 Starting Call Intelligence Docker Services..."
cd "$(dirname "$0")/.."
docker-compose -f docker-compose.dev.yml up -d
echo "⏳ Waiting for services..."
sleep 10
echo "✅ Services started!"
echo "📊 Neo4j: http://localhost:7474"
echo "📊 Adminer: http://localhost:8080"
