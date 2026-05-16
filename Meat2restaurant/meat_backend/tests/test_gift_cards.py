import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1])) # Add project root

import pytest
from datetime import datetime, timedelta
from app import models
from app.api import deps

# Mock user for dependency override
mock_superuser = models.User(id=1, email="admin@example.com", is_superuser=True, is_active=True)
mock_superuser.identity_type = "staff"

def override_get_current_active_superuser():
    return mock_superuser

def override_get_current_active_user():
    return mock_superuser

def test_gift_card_lifecycle(client, db):
    # 1. Override Auth Configuration
    from app.main import app
    app.dependency_overrides[deps.get_current_active_superuser] = override_get_current_active_superuser
    
    # 2. Create Gift Card
    expiry = datetime.utcnow() + timedelta(days=365)
    card_data = {
        "code": "TEST-CARD-100",
        "initial_amount": 100.0,
        "current_balance": 100.0,
        "expiry_date": expiry.isoformat(),
        "is_active": True
    }
    response = client.post("/api/v1/sales/gift-cards", json=card_data)
    assert response.status_code == 200
    card = response.json()
    assert card["code"] == "TEST-CARD-100"
    assert card["current_balance"] == 100.0
    
    # 3. Read Gift Cards
    response = client.get("/api/v1/sales/gift-cards")
    assert response.status_code == 200
    assert len(response.json()) >= 1
    
    # 4. Redeem Success
    redeem_data = {
        "code": "TEST-CARD-100",
        "amount": 20.0
    }
    response = client.post("/api/v1/sales/gift-cards/redeem", json=redeem_data)
    assert response.status_code == 200
    updated_card = response.json()
    assert updated_card["current_balance"] == 80.0
    
    # 5. Redeem Insufficient Funds
    redeem_data["amount"] = 90.0 # Only 80 left
    response = client.post("/api/v1/sales/gift-cards/redeem", json=redeem_data)
    assert response.status_code == 400
    assert "Insufficient balance" in response.text
    
    # 6. Redeem Invalid Code
    redeem_data["code"] = "INVALID-CODE"
    response = client.post("/api/v1/sales/gift-cards/redeem", json=redeem_data)
    assert response.status_code == 404
