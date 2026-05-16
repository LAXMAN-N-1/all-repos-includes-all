
import requests
import json
from datetime import datetime, timedelta

BASE_URL = "http://localhost:8000/api/v1"

# 1. Login Logic (Reusable)
def login(email, password):
    resp = requests.post(f"{BASE_URL}/auth/login", data={"username": email, "password": password})
    if resp.status_code == 200:
        return resp.json()['access_token']
    print(f"Login failed: {resp.text}")
    return None

# 2. Main Test Flow
def test_invoice_flow():
    token = login("admin@b2bmeat.com", "password123")
    headers = {"Authorization": f"Bearer {token}"}
    
    # Step A: Get a recent order (or create one if none)
    # For now, let's fetch orders and pick the first one
    print("\n--- Fetching Orders ---")
    resp = requests.get(f"{BASE_URL}/orders/", headers=headers)
    try:
        orders = resp.json()
    except Exception:
        print(f"FAILED to parse JSON. Status: {resp.status_code}")
        print(f"Response: {resp.text}")
        return
    
    if not orders:
        print("No orders found to invoice. Creating one...")
        # Create a dummy order logic if needed, but assuming seed data exists
        return

    order_id = orders[0]['id']
    customer_id = orders[0]['customer_id']
    amount = orders[0]['total_amount']
    print(f"Selected Order #{order_id} for Customer {customer_id} (Amount: ${amount})")

    # Step B: Generate Invoice
    print(f"\n--- Creating Invoice for Order #{order_id} ---")
    payload = {
        "customer_id": customer_id,
        "order_id": order_id,
        "amount_due": amount,
        "due_date": (datetime.utcnow() + timedelta(days=30)).isoformat(),
        "status": "draft"
    }
    
    resp = requests.post(f"{BASE_URL}/invoices/", json=payload, headers=headers)
    if resp.status_code == 200:
        inv = resp.json()
        print(f"✅ Invoice Created: ID {inv['id']}")
        print(f"📄 PDF URL: {inv['pdf_url']}")
        
        # Verify PDF URL is not null
        if inv['pdf_url']:
            print("SUCCESS: PDF URL generated.")
        else:
            print("FAILURE: PDF URL is missing.")
    else:
        print(f"❌ Failed to create invoice: {resp.text}")

if __name__ == "__main__":
    test_invoice_flow()
