import sys
from pathlib import Path
# Insert project root to path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import pytest
from app import models
from app.api import deps

# Mock user for dependency override
mock_superuser = models.User(id=1, email="admin@example.com", is_superuser=True, is_active=True)
# Ensure identity_type is set if checked (dynamic attribute)
mock_superuser.identity_type = "staff"

mock_customer = models.Customer(id=1, email="client@example.com", name="Test Client")

def override_get_current_active_superuser():
    return mock_superuser

def override_get_current_active_user():
    return mock_superuser

def test_membership_lifecycle(client, db):
    # 1. Override Auth Configuration
    from app.main import app
    app.dependency_overrides[deps.get_current_active_superuser] = override_get_current_active_superuser
    app.dependency_overrides[deps.get_current_active_user] = override_get_current_active_user
    
    # 2. Setup Data (Customer)
    # Ensure customer doesn't exist to prevent unique constraint error if DB not cleaned
    existing = db.query(models.Customer).filter(models.Customer.email == mock_customer.email).first()
    if not existing:
        db.add(mock_customer)
        db.commit()
        customer_id = mock_customer.id
    else:
        customer_id = existing.id
    
    # 3. Create Membership Plan
    plan_data = {
        "name": "Gold Tier Unit Test",
        "description": "Premium access test",
        "price": 99,
        "duration_days": 30,
        "benefits": "Free shipping",
        "is_active": True
    }
    response = client.post("/api/v1/customers/membership-plans", json=plan_data)
    assert response.status_code == 200
    plan = response.json()
    assert plan["name"] == "Gold Tier Unit Test"
    assert plan["id"] is not None
    plan_id = plan["id"]
    
    # 4. Read Plans
    response = client.get("/api/v1/customers/membership-plans")
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 1
    names = [p["name"] for p in data]
    assert "Gold Tier Unit Test" in names
    
    # 5. Assign Membership to Customer
    assign_data = {
        "plan_id": plan_id,
        "customer_id": customer_id
    }
    response = client.post(f"/api/v1/customers/{customer_id}/membership", json=assign_data)
    if response.status_code != 200:
        print(f"Assign Failure: {response.text}")
    assert response.status_code == 200
    membership = response.json()
    assert membership["plan_id"] == plan_id
    assert membership["is_active"] is True
    assert membership["end_date"] is not None
    
    # 6. Verify Customer Read includes Membership
    response = client.get(f"/api/v1/customers/{customer_id}/membership")
    assert response.status_code == 200
    m_data = response.json()
    assert m_data["plan_id"] == plan_id
    
    # 7. Cancel Membership
    response = client.delete(f"/api/v1/customers/{customer_id}/membership")
    assert response.status_code == 200
    
    # Verify cancellation (GET should 404)
    response = client.get(f"/api/v1/customers/{customer_id}/membership")
    assert response.status_code == 404
