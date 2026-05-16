"""
Test script to verify volume_tiers fix
"""
import requests
import json

BASE_URL = "http://127.0.0.1:8000/api/v1"

# First, we need to login to get a token
# Using admin credentials from seed data
login_data = {
    "username": "admin@b2bmeat.com",
    "password": "password123"
}

print("🔐 Logging in...")
try:
    response = requests.post(f"{BASE_URL}/auth/login", data=login_data)
    if response.status_code == 200:
        token = response.json()["access_token"]
        print("✅ Login successful!")
    else:
        print(f"❌ Login failed: {response.status_code}")
        print(f"Response: {response.text}")
        print("\n⚠️ Please update the login credentials in the script and try again.")
        exit(1)
except Exception as e:
    print(f"❌ Error during login: {e}")
    exit(1)

# Create headers with token
headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

# Test product data with volume_tiers
test_product = {
    "name": "Test Chicken Breast with Volume Tiers",
    "description": "Premium chicken breast for testing volume tiers",
    "price": 45.0,
    "wholesale_price": 40.0,
    "sku": f"TEST-CHICKEN-{json.dumps({}).__hash__() % 10000}",  # Random SKU
    "stock_quantity": 100,
    "unit": "lb",
    "min_order_quantity": 1,
    "volume_tiers": {
        "10": 42.0,
        "50": 38.0,
        "100": 35.0
    },
    "is_active": True,
    "category": "Poultry"
}

print("\n📦 Creating test product with volume_tiers...")
print(f"Volume tiers being sent: {test_product['volume_tiers']}")

try:
    response = requests.post(
        f"{BASE_URL}/products/",
        headers=headers,
        json=test_product
    )
    
    if response.status_code == 200:
        product = response.json()
        print("\n✅ Product created successfully!")
        print(f"Product ID: {product.get('id')}")
        print(f"Product Name: {product.get('name')}")
        print(f"Volume Tiers in Response: {product.get('volume_tiers')}")
        
        if product.get('volume_tiers') is None:
            print("\n❌ ISSUE: volume_tiers is still NULL!")
        elif product.get('volume_tiers') == test_product['volume_tiers']:
            print("\n🎉 SUCCESS: volume_tiers is correctly stored and retrieved!")
        else:
            print(f"\n⚠️ WARNING: volume_tiers mismatch!")
            print(f"Expected: {test_product['volume_tiers']}")
            print(f"Got: {product.get('volume_tiers')}")
            
        # Verify by fetching the product again
        print("\n🔍 Fetching product again to verify persistence...")
        get_response = requests.get(
            f"{BASE_URL}/products/{product.get('id')}",
            headers=headers
        )
        
        if get_response.status_code == 200:
            fetched_product = get_response.json()
            print(f"Volume Tiers from GET: {fetched_product.get('volume_tiers')}")
            
            if fetched_product.get('volume_tiers') == test_product['volume_tiers']:
                print("\n✅ VERIFIED: volume_tiers persists correctly in database!")
            else:
                print("\n❌ ISSUE: volume_tiers not persisting correctly!")
        
    else:
        print(f"\n❌ Failed to create product: {response.status_code}")
        print(f"Response: {response.text}")
        
except Exception as e:
    print(f"\n❌ Error during product creation: {e}")
