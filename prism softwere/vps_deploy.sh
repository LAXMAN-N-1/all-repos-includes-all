#!/bin/bash

# Configuration
APP_DIR="/var/www/prism"

echo "🚀 Starting VPS Deployment for Prism..."

# 1. Backend
echo "🔧 Updating Backend..."
cd "$APP_DIR/backend" || { echo "❌ Directory $APP_DIR/backend not found"; exit 1; }
git pull origin main
npm install
npm run build
echo "✅ Backend updated"

# 2. Frontend
echo "🏗️ Building Frontend..."
cd "$APP_DIR/frontend" || { echo "❌ Directory $APP_DIR/frontend not found"; exit 1; }
git pull origin main

echo "🧹 Cleaning old build files..."
rm -rf .next

echo "📝 Setting production environment..."
cat > .env.production << 'EOF'
# Backend runs on port 5002 on this VPS
BACKEND_INTERNAL_URL=http://127.0.0.1:5002
EOF

echo "📦 Installing dependencies..."
npm install

echo "🏗️ Building Next.js app..."
npm run build

# 3. Restart all processes
echo "🔄 Restarting application..."
if command -v pm2 &> /dev/null
then
    pm2 restart all
else
    echo "⚠️ PM2 not found, please restart manually"
fi

echo "✅ Deployment complete! Visit https://prism.powerfrill.com"
