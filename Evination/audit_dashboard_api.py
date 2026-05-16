import requests
import json
import os

BASE_URL = "http://localhost:8000/api"

# ⚠️ IMPORTANT: Set AUTH_TOKEN via environment variable or replace below
# Example: export AUTH_TOKEN="your_token_here"
# Or get a token: curl -X POST "http://localhost:8000/api/auth/token" -d "username=admin@evination.com&password=Admin@123"
AUTH_TOKEN = os.getenv("AUTH_TOKEN", "YOUR_TOKEN_HERE")

HEADERS = {"Authorization": f"Bearer {AUTH_TOKEN}"}

endpoints = [
    # ADMIN DASHBOARD
    "/api/admin/dashboard/financials",
    "/api/admin/dashboard/activity",
    
    # VENDOR DASHBOARD
    "/vendor/dashboard",
    
    # ADMIN ANALYTICS
    "/admin/analytics/stats",
    "/admin/analytics/revenue-trends",
    "/admin/analytics/event-analytics",
    "/admin/analytics/revenue-by-category",
    "/admin/analytics/top-vendors",
    
    # VENDOR ANALYTICS
    "/vendor/analytics/stats",
    "/vendor/analytics/notifications",
    "/vendor/analytics/charts",
    
    # CONSUMER ANALYTICS
    "/consumer/dashboard/favorites",
    "/consumer/dashboard/suggested",
    "/consumer/dashboard/history"
]

results = []

print("🧪 Final Dashboard & Analytics Audit...")

if AUTH_TOKEN == "YOUR_TOKEN_HERE":
    print("⚠️  WARNING: No auth token set! Set AUTH_TOKEN env variable or edit this file.")
    print("   Example: set AUTH_TOKEN=your_jwt_token_here")

for ep in endpoints:
    url = f"{BASE_URL}{ep}"
    try:
        res = requests.get(url, headers=HEADERS)
        print(f"[{res.status_code}] {ep}")
        results.append({
            "endpoint": ep,
            "status": res.status_code,
            "working": res.status_code == 200
        })
    except Exception as e:
        print(f"[ERROR] {ep}: {str(e)}")
        results.append({
            "endpoint": ep,
            "status": "ERROR",
            "error": str(e)
        })

working_count = sum(1 for r in results if r.get('working'))
print(f"\n📊 Audit Result: {working_count}/{len(endpoints)} endpoints working.")
