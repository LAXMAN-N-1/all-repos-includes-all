"""
Unit tests for auth endpoints
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app import models
from app.core import security


class TestAuthEndpoints:
    """Test authentication endpoints"""
    
    def test_login_staff_success(self, client: TestClient, db: Session):
        """Test successful staff login"""
        # Create a staff user
        hashed_password = security.get_password_hash("testpass123")
        staff = models.User(
            email="staff@test.com",
            full_name="Test Staff",
            hashed_password=hashed_password,
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(staff)
        db.commit()
        
        # Attempt login
        response = client.post(
            "/api/v1/auth/login",
            data={"username": "staff@test.com", "password": "testpass123"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"
        assert data["user"]["identity_type"] == "staff"
        assert data["user"]["email"] == "staff@test.com"
    
    def test_login_partner_success(self, client: TestClient, db: Session):
        """Test successful partner login"""
        # Create a partner customer
        hashed_password = security.get_password_hash("partnerpass123")
        partner = models.Customer(
            email="partner@test.com",
            name="Test Partner",
            phone="1234567890",
            hashed_password=hashed_password,
            customer_type="b2b",
            is_active=True,
            is_verified=True,
            status="approved"
        )
        db.add(partner)
        db.commit()
        
        # Attempt login
        response = client.post(
            "/api/v1/auth/login",
            data={"username": "partner@test.com", "password": "partnerpass123"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"
        assert data["user"]["identity_type"] == "partner"
        assert data["user"]["email"] == "partner@test.com"
    
    def test_login_invalid_credentials(self, client: TestClient, db: Session):
        """Test login with invalid credentials"""
        response = client.post(
            "/api/v1/auth/login",
            data={"username": "nonexistent@test.com", "password": "wrongpass"}
        )
        
        assert response.status_code == 400
        assert "Incorrect email, phone or password" in response.json()["detail"]
    
    def test_login_inactive_staff(self, client: TestClient, db: Session):
        """Test login with inactive staff account"""
        hashed_password = security.get_password_hash("testpass123")
        staff = models.User(
            email="inactive@test.com",
            full_name="Inactive Staff",
            hashed_password=hashed_password,
            role="admin",
            is_active=False,
            is_superuser=False
        )
        db.add(staff)
        db.commit()
        
        response = client.post(
            "/api/v1/auth/login",
            data={"username": "inactive@test.com", "password": "testpass123"}
        )
        
        assert response.status_code == 400
        assert "Inactive staff account" in response.json()["detail"]
    
    def test_register_new_customer(self, client: TestClient, db: Session):
        """Test successful customer registration"""
        customer_data = {
            "name": "New Business",
            "email": "newbiz@test.com",
            "phone": "9876543210",
            "password": "securepass123",
            "business_name": "New Business LLC",
            "address": "123 Test St",
            "customer_type": "b2b"
        }
        
        response = client.post("/api/v1/auth/register", json=customer_data)
        
        assert response.status_code == 200
        data = response.json()
        assert data["email"] == "newbiz@test.com"
        assert data["name"] == "New Business"
        assert data["customer_type"] == "b2b"
        assert data["is_verified"] == True
        assert data["status"] in ("submitted", "approved")
    
    def test_register_duplicate_email(self, client: TestClient, db: Session):
        """Test registration with existing email"""
        # Create existing customer
        existing = models.Customer(
            email="existing@test.com",
            name="Existing Business",
            phone="1111111111",
            hashed_password=security.get_password_hash("pass123"),
            customer_type="b2b"
        )
        db.add(existing)
        db.commit()
        
        # Try to register with same email
        customer_data = {
            "name": "Another Business",
            "email": "existing@test.com",
            "phone": "2222222222",
            "password": "newpass123",
            "business_name": "Another LLC",
            "address": "456 Test Ave"
        }
        
        response = client.post("/api/v1/auth/register", json=customer_data)
        
        assert response.status_code == 400
        assert "already registered" in response.json()["detail"]
