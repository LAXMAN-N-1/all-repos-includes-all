import requests
import json
import sys

BASE_URL = "http://localhost:8000/api"

def print_step(msg):
    print(f"\n[STEP] {msg}")

def login(email, password):
    url = f"{BASE_URL}/auth/login"
    try:
        resp = requests.post(url, json={"username": email, "password": password})
        if resp.status_code == 200:
            return resp.json()["access_token"]
        print(f"Login failed: {resp.text}")
    except Exception as e:
        print(f"Login error: {e}")
    return None

def register_user(email, password, role="vendor"):
    # This might need adjustment depending on how registration works now
    # Assuming there's a public registration or we use seed data
    # For now, let's assume we can create a user via some endpoint or use existing
    pass

def main():
    # 1. Login as Admin
    print_step("Logging in as Admin")
    admin_token = login("laxmanlaxman1629@gmail.com", "laxman123")
    if not admin_token:
        print("Failed to login as admin. Exiting.")
        return

    # 2. Login as a User who wants to be a Vendor (or create one)
    # Since we can't easily register via public API in this script without knowing the specific route
    # We will assume a user exists or use a new one if possible. 
    # Let's try to login as a potential vendor user.
    print_step("Logging in as Vendor User")
    # Note: In real world, user would register first. Here assuming existing or creating via direct means if allowed.
    # For this test, I will skip user creation and assume 'vendor_user_1@test.com' exists or failed.
    # To make this robust, I should probably create a user using admin endpoint first.
    
    headers_admin = {"Authorization": f"Bearer {admin_token}"}
    
    new_user_email = f"vendor_test_{sys.version_info.major}@example.com"
    # Create user via Admin API
    create_user_resp = requests.post(
        f"{BASE_URL}/users/",
        headers=headers_admin,
        json={
            "email": new_user_email,
            "username": new_user_email, # using email as username
            "password": "password123",
            "first_name": "Test",
            "last_name": "Vendor",
            "role_id": 3, # Assuming 3 is Vendor role, 2 was Admin likely?
            "phone_number": "9998887776"
        }
    )
    
    if create_user_resp.status_code not in [200, 201]:
        print(f"Failed to create user: {create_user_resp.text}")
        # Proceeding might fail if user doesn't exist
    
    vendor_token = login(new_user_email, "password123")
    if not vendor_token:
        print("Start backend first? Login failed for new user.")
        return

    headers_vendor = {"Authorization": f"Bearer {vendor_token}"}

    # 3. Initiate Onboarding
    print_step("Initiating Onboarding")
    init_data = {
        "vendor_type": "company",
        "company_name": "Test Events Pvt Ltd",
        "contact_person": "Mr. Tester",
        "phone": "9998887776",
        "email": new_user_email
    }
    resp = requests.post(f"{BASE_URL}/onboarding/initiate", headers=headers_vendor, json=init_data)
    print(f"Initiate Status: {resp.status_code}")
    print(resp.json())
    
    if resp.status_code != 200:
        return

    # 4. Save Business Details
    print_step("Saving Business Details")
    biz_data = {
        "company_name": "Test Events Pvt Ltd",
        "trade_name": "Test Events",
        "city": "Mumbai",
        "state": "Maharashtra",
        "coverage_areas": ["Mumbai", "Pune"],
        "categories": [
            {
                "category_id": 1, # Assuming cat 1 exists
                "price_min": 50000,
                "experience_years": 5
            }
        ]
    }
    resp = requests.patch(f"{BASE_URL}/onboarding/details", headers=headers_vendor, json=biz_data)
    print(f"Details Status: {resp.status_code}")
    print(resp.json())

    # 5. Upload Documents
    print_step("Uploading Documents (Mock)")
    doc_data = {
        "documents": [
            {"type": "gst", "url": "http://s3.bucket/gst.pdf", "number": "27ABCDE1234F1Z5"},
            {"type": "pan", "url": "http://s3.bucket/pan.jpg", "number": "ABCDE1234F"}
        ]
    }
    resp = requests.post(f"{BASE_URL}/onboarding/documents", headers=headers_vendor, json=doc_data)
    print(f"Docs Status: {resp.status_code}")
    print(resp.json())

    # 6. Submit Application
    print_step("Submitting Application")
    resp = requests.post(f"{BASE_URL}/onboarding/submit", headers=headers_vendor)
    print(f"Submit Status: {resp.status_code}")
    print(resp.json())

    # 7. Admin Review
    print_step("Admin Verifying Pending Vendors")
    resp = requests.get(f"{BASE_URL}/admin/vendors/pending", headers=headers_admin)
    print(f"Pending List Status: {resp.status_code}")
    vendors = resp.json()
    print(f"Found {len(vendors)} pending vendors")
    
    target_vendor = None
    for v in vendors:
        if v['email'] == new_user_email:
            target_vendor = v
            break
            
    if not target_vendor:
        print("Vendor not found in pending list!")
        return

    vendor_id = target_vendor['id']
    print(f"Verifying Vendor ID: {vendor_id}")

    # 8. Admin Approve Vendor
    print_step("Admin Approving Vendor")
    resp = requests.post(f"{BASE_URL}/admin/vendors/{vendor_id}/approve", headers=headers_admin)
    print(f"Approve Status: {resp.status_code}")
    print(resp.json())
    
    if resp.status_code == 200:
        print("\n✅ Verification SUCCESS! Vendor onboarding flow is working.")

if __name__ == "__main__":
    main()
