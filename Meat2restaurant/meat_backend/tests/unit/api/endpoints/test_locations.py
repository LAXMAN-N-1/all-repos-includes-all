"""
Unit tests for locations endpoints
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app import models
from app.core import security


class TestLocationsEndpoints:
    """Test location endpoints"""
    
    def test_create_location_as_partner(self, client: TestClient, db: Session):
        """Test creating a location as a partner"""
        # Create partner
        partner = models.Customer(
            email="partner@test.com",
            name="Test Partner",
            phone="1234567890",
            hashed_password=security.get_password_hash("pass"),
            customer_type="b2b",
            is_active=True,
            is_verified=True,
            status="verified"
        )
        db.add(partner)
        db.commit()
        db.refresh(partner)
        
        # Login
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "partner@test.com", "password": "pass"}
        )
        token = login_response.json()["access_token"]
        
        # Create location
        location_data = {
            "customer_id": partner.id,
            "name": "Main Warehouse",
            "address": "123 Test St",
            "city": "Test City",
            "state": "TS",
            "zip_code": "12345",
            "is_default": True
        }
        
        response = client.post(
            "/api/v1/locations/",
            json=location_data,
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "Main Warehouse"
        assert data["customer_id"] == partner.id
    
    def test_read_locations_partner_sees_only_own(self, client: TestClient, db: Session):
        """Test that partners can only see their own locations"""
        # Create two partners
        partner1 = models.Customer(
            email="partner1@test.com",
            name="Partner 1",
            phone="1111111111",
            hashed_password=security.get_password_hash("pass1"),
            customer_type="b2b",
            is_active=True
        )
        partner2 = models.Customer(
            email="partner2@test.com",
            name="Partner 2",
            phone="2222222222",
            hashed_password=security.get_password_hash("pass2"),
            customer_type="b2b",
            is_active=True
        )
        db.add_all([partner1, partner2])
        db.commit()
        db.refresh(partner1)
        db.refresh(partner2)
        
        # Create locations
        location1 = models.Location(
            customer_id=partner1.id,
            name="Location 1",
            address="Address 1"
        )
        location2 = models.Location(
            customer_id=partner2.id,
            name="Location 2",
            address="Address 2"
        )
        db.add_all([location1, location2])
        db.commit()
        
        # Login as partner1
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "partner1@test.com", "password": "pass1"}
        )
        token = login_response.json()["access_token"]
        
        # Get locations
        response = client.get(
            "/api/v1/locations/",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        locations = response.json()
        assert len(locations) == 1
        assert locations[0]["customer_id"] == partner1.id
