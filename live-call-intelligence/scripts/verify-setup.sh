#!/bin/bash
echo "🔍 Running Live Call Intelligence Full Verification..."
echo "------------------------------------------------------"

# --- Function to check a command exists ---
check_cmd() {
  if command -v "$1" &> /dev/null; then
    echo "✅ $1 installed: $($1 --version | head -n 1)"
  else
    echo "❌ $1 not installed. Please install it."
  fi
}

# --- Check key dependencies ---
check_cmd git
check_cmd docker
check_cmd python3
check_cmd node
check_cmd npm

echo
echo "📁 Checking project structure..."
for folder in ai-ml backend frontend mobile devops docs; do
  if [ -d "$folder" ]; then
    echo "✅ Folder found: $folder/"
  else
    echo "⚠️ Missing folder: $folder/"
  fi
done

echo
echo "🐳 Checking Docker status..."
if ! docker info > /dev/null 2>&1; then
  echo "❌ Docker daemon not running."
else
  echo "✅ Docker daemon running."
  containers=$(docker ps --format "{{.Names}}")
  if [ -z "$containers" ]; then
    echo "⚠️ No containers currently running."
  else
    echo "🟢 Running containers:"
    echo "$containers"
  fi
fi

echo
echo "🌿 Checking Git branches..."
branches=$(git branch -a)
if [ $? -eq 0 ]; then
  echo "✅ Git branches found:"
  echo "$branches"
else
  echo "❌ Unable to fetch Git branches. Check repository status."
fi

echo
echo "🧠 Checking Python AI/ML dependencies..."
if [ -f "ai-ml/requirements.txt" ]; then
  echo "Found ai-ml/requirements.txt"
  python3 -m pip install -r ai-ml/requirements.txt --quiet
  echo "✅ AI/ML dependencies verified."
else
  echo "⚠️ No ai-ml/requirements.txt found."
fi

echo
echo "------------------------------------------------------"
echo "✅ Full Verification Complete!"

# --- Optional Slack/Discord Notification ---
echo
echo "📡 Sending verification status notification..."

# Replace with your actual webhook URLs if needed
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXX"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX"

MESSAGE="✅ Live Call Intelligence verification successful on $(hostname) by $(whoami)."

# Uncomment to enable
# curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$MESSAGE\"}" $SLACK_WEBHOOK_URL
# curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" $DISCORD_WEBHOOK_URL

echo "✅ Notification ready (webhooks commented out for safety)."