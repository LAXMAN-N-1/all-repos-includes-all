"""
Unit tests for settings endpoints
"""
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from app import models
from app.core import security

class TestSettingsEndpoints:
    """Test settings endpoints"""
    
    def test_delivery_zone_crud(self, client: TestClient, db: Session):
        """Test Delivery Zone CRUD operations"""
        # 1. Create superuser
        superuser = models.User(
            email="admin_settings@test.com",
            full_name="Settings Admin",
            hashed_password=security.get_password_hash("adminpass"),
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(superuser)
        db.commit()

        # Login
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "admin_settings@test.com", "password": "adminpass"}
        )
        token = login_response.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # 2. CREATE Delivery Zone
        create_data = {"name": "Test Zone", "zip_codes": "10001,10002", "fee": 15.0}
        response = client.post("/api/v1/settings/delivery-zones", json=create_data, headers=headers)
        assert response.status_code == 200
        zone = response.json()
        assert zone["name"] == "Test Zone"
        zone_id = zone["id"]

        # 3. READ Delivery Zones
        response = client.get("/api/v1/settings/delivery-zones", headers=headers)
        assert response.status_code == 200
        assert len(response.json()) >= 1

        # 4. UPDATE Delivery Zone
        update_data = {"fee": 20.0}
        response = client.put(f"/api/v1/settings/delivery-zones/{zone_id}", json=update_data, headers=headers)
        assert response.status_code == 200
        assert response.json()["fee"] == 20.0

        # 5. DELETE Delivery Zone
        response = client.delete(f"/api/v1/settings/delivery-zones/{zone_id}", headers=headers)
        assert response.status_code == 200

        # Verify deletion
        # Depending on implementation, reading list should not contain it, or direct read if implemented
        # Since we only implemented list read for now in the plan (check implementation), let's check list
        response = client.get("/api/v1/settings/delivery-zones", headers=headers)
        zones = response.json()
        assert not any(z['id'] == zone_id for z in zones)

    def test_config_description_and_shipping_days(self, client: TestClient, db: Session):
        """Test Configuration description and Shipping estimated_days"""
        # Login (reuse logic or assume distinct test isolation, safer to re-login if needed but we have DB fixture)
        # Using existing user from prev test might fail due to DB rollback policies or if it's per function
        # Let's creating a new one just in case or rely on fixture. 
        # Assuming function scope fixture 'db' cleans up.
        
        superuser = models.User(
            email="admin_settings_2@test.com",
            full_name="Settings Admin 2",
            hashed_password=security.get_password_hash("adminpass"),
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(superuser)
        db.commit()

        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "admin_settings_2@test.com", "password": "adminpass"}
        )
        token = login_response.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # 1. Test Config Description
        config_data = {
            "key": "TEST_FEATURE",
            "value": "enabled",
            "description": "A test feature toggle"
        }
        response = client.put("/api/v1/settings/configs", json=config_data, headers=headers)
        assert response.status_code == 200
        
        # Verify description retrieval
        response = client.get("/api/v1/settings/configs/details", headers=headers)
        assert response.status_code == 200
        configs = response.json()
        test_config = next((c for c in configs if c['key'] == "TEST_FEATURE"), None)
        assert test_config is not None
        assert test_config['description'] == "A test feature toggle"

        # 2. Test Shipping Estimated Days
        shipping_data = {
            "name": "Fast Ship",
            "price": 50.0,
            "estimated_days": 1
        }
        response = client.post("/api/v1/settings/shipping", json=shipping_data, headers=headers)
        assert response.status_code == 200
        method = response.json()
        assert method['estimated_days'] == 1
