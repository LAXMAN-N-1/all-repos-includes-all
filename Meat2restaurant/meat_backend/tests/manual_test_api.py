"""
API Endpoint Testing Script
Tests various endpoints to verify the application is working correctly
"""
import requests
import json

BASE_URL = "http://localhost:8000"

def test_endpoint(name, url, method="GET", data=None):
    """Test a single endpoint and print results"""
    print(f"\n{'='*60}")
    print(f"Testing: {name}")
    print(f"URL: {url}")
    print(f"Method: {method}")
    
    try:
        if method == "GET":
            response = requests.get(url)
        elif method == "POST":
            response = requests.post(url, json=data)
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ SUCCESS")
            try:
                data = response.json()
                print(f"Response: {json.dumps(data, indent=2)[:500]}")
            except:
                print(f"Response: {response.text[:500]}")
        else:
            print("❌ FAILED")
            print(f"Response: {response.text[:500]}")
            
    except Exception as e:
        print(f"❌ ERROR: {str(e)}")

# Run tests
print("🚀 Starting API Tests...")
print(f"Base URL: {BASE_URL}")

# Test basic endpoints
test_endpoint("Health Check", f"{BASE_URL}/health")
test_endpoint("Root Endpoint", f"{BASE_URL}/")

# Test API v1 endpoints
test_endpoint("Get Products", f"{BASE_URL}/api/v1/products/")
test_endpoint("Get Customers", f"{BASE_URL}/api/v1/customers/")
test_endpoint("Get Orders", f"{BASE_URL}/api/v1/orders/")
test_endpoint("Get Categories", f"{BASE_URL}/api/v1/catalog/categories")
test_endpoint("Get Locations", f"{BASE_URL}/api/v1/locations/")
test_endpoint("Get Promotions", f"{BASE_URL}/api/v1/promotions/")
test_endpoint("Get Shipping Methods", f"{BASE_URL}/api/v1/settings/shipping")

print(f"\n{'='*60}")
print("✅ API Testing Complete!")
print(f"\n📖 View full API documentation at: {BASE_URL}/docs")
print(f"{'='*60}\n")
