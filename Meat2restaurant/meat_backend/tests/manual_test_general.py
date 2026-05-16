import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))

import traceback

try:
    from fastapi.testclient import TestClient
    from app.main import app
    from app.api import deps
    from app import models
    from app.db.session import SessionLocal
    
    print("Imports successful")
    print(f"deps content: {dir(deps)}")
    
    # Setup Auth Override
    mock_superuser = models.User(id=9999, email="admin_test@example.com", is_superuser=True, is_active=True)
    # Add identity_type just in case the endpoint logic uses it indirectly (it shouldn't but safe side)
    mock_superuser.identity_type = "staff" 
    
    def override_user(): 
        return mock_superuser

    app.dependency_overrides[deps.get_current_active_superuser] = override_user
    app.dependency_overrides[deps.get_current_active_user] = override_user
    print("Overrides set")

    client = TestClient(app)
    print("Client created")

    print("1. Creating Membership Plan...")
    plan_data = {
        "name": "Manual Plan",
        "description": "Manual Test",
        "price": 10,
        "duration_days": 7,
        "is_active": True
    }
    resp = client.post("/api/v1/customers/membership-plans", json=plan_data)
    print(f"Status: {resp.status_code}")
    if resp.status_code != 200:
        print(f"Error: {resp.text}")
    else:
        print(f"Plan Created. JSON: {resp.json()}")
        plan_id = resp.json()['id']
        
        print("2. Assigning Membership...")
        db = SessionLocal()
        cust = db.query(models.Customer).first()
        if not cust:
             print("Creating temp customer")
             cust = models.Customer(name="Test Cust", email="test@test.com")
             db.add(cust)
             db.commit()
             db.refresh(cust)
        print(f"Customer ID: {cust.id}")
        
        assign_data = {"plan_id": plan_id, "customer_id": cust.id}
        resp2 = client.post(f"/api/v1/customers/{cust.id}/membership", json=assign_data)
        print(f"Assign Status: {resp2.status_code}")
        print(f"Assign Body: {resp2.text}")
        
        print("3. Cleaning up...")
        client.delete(f"/api/v1/customers/{cust.id}/membership")
        client.delete(f"/api/v1/customers/membership-plans/{plan_id}")
        
    print("MANUAL TEST COMPLETED")

except Exception:
    traceback.print_exc()
