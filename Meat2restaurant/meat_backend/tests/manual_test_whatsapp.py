
import requests

URL = "http://localhost:8000/api/v1/whatsapp/webhook"

# 1. Test Catalog
print("\n--- Testing Catalog ---")
resp = requests.post(URL, data={"From": "whatsapp:+15550202", "Body": "CATALOG"})
print(resp.text)

# 2. Test Ordering (Ribeye)
print("\n--- Testing Order (Ribeye) ---")
resp = requests.post(URL, data={"From": "whatsapp:+15550202", "Body": "Order 2 Ribeye"})
print(resp.text)

# 3. Test Checking Status (Use a fake ID for now, or regex parser result)
print("\n--- Testing Status ---")
resp = requests.post(URL, data={"From": "whatsapp:+15550202", "Body": "Order 1"}) # Assuming ID 1 exists
print(resp.text)
