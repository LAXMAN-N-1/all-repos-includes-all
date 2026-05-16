"""
Authentication Endpoint Integration Tests
==========================================
Tests for /api/auth/login and /api/auth/token endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


class TestAuthLogin:
    """Tests for POST /api/auth/login endpoint"""
    
    def test_login_success(self, client: TestClient, admin_user):
        """Test successful login returns token and user data"""
        response = client.post("/api/auth/login", json={
            "email": "admin@test.com",  # LoginRequest expects email, not username
            "password": "Admin@123"
        })
        
        assert response.status_code == 200
        data = response.json()
        
        # Verify token is returned
        assert "access_token" in data
        assert data["token_type"] == "bearer"
        
        # Verify user data is returned
        assert "user" in data
        assert data["user"]["username"] == "testadmin"
        assert data["user"]["email"] == "admin@test.com"
    
    def test_login_invalid_username(self, client: TestClient, admin_user):
        """Test login fails with invalid email"""
        response = client.post("/api/auth/login", json={
            "email": "nonexistent@test.com",
            "password": "Admin@123"
        })
        
        assert response.status_code == 401
        assert "Invalid credentials" in response.json()["detail"]
    
    def test_login_invalid_password(self, client: TestClient, admin_user):
        """Test login fails with invalid password"""
        response = client.post("/api/auth/login", json={
            "email": "admin@test.com",
            "password": "WrongPassword"
        })
        
        assert response.status_code == 401
        assert "Invalid credentials" in response.json()["detail"]
    
    def test_login_inactive_user(self, client: TestClient, db: Session, seed_superadmin_role):
        """Test login fails for inactive users"""
        from app.models.user_m import User
        from app.utils.password_utils import hash_password
        
        # Create inactive user
        inactive_user = User(
            username="inactive_user",
            email="inactive@test.com",
            password_hash=hash_password("Test@123"),
            first_name="Inactive",
            last_name="User",
            role_id=seed_superadmin_role.id,
            inactive=True  # User is inactive
        )
        db.add(inactive_user)
        db.commit()
        
        response = client.post("/api/auth/login", json={
            "email": "inactive@test.com",
            "password": "Test@123"
        })
        
        assert response.status_code == 401
    
    def test_login_empty_credentials(self, client: TestClient):
        """Test login fails with empty credentials"""
        response = client.post("/api/auth/login", json={
            "email": "",
            "password": ""
        })
        
        # Should fail validation or auth
        assert response.status_code in [401, 422]


class TestAuthToken:
    """Tests for POST /api/auth/token endpoint (OAuth2 compatible)"""
    
    def test_token_success(self, client: TestClient, admin_user):
        """Test OAuth2 token endpoint returns access token"""
        # OAuth2 form expects email in username field for this endpoint
        response = client.post("/api/auth/token", data={
            "username": "admin@test.com",  # OAuth2 sends email in username field
            "password": "Admin@123"
        })
        
        assert response.status_code == 200
        data = response.json()
        
        assert "access_token" in data
        assert data["token_type"] == "bearer"
    
    def test_token_invalid_credentials(self, client: TestClient, admin_user):
        """Test token endpoint fails with invalid credentials"""
        response = client.post("/api/auth/token", data={
            "username": "admin@test.com",
            "password": "WrongPassword"
        })
        
        assert response.status_code == 401


class TestVendorLogin:
    """Tests for vendor authentication"""
    
    def test_vendor_login_success(self, client: TestClient, vendor_user):
        """Test vendor can login successfully"""
        response = client.post("/api/auth/login", json={
            "email": "vendor@test.com",
            "password": "Vendor@123"
        })
        
        assert response.status_code == 200
        data = response.json()
        assert data["user"]["username"] == "testvendor"


class TestConsumerLogin:
    """Tests for consumer authentication"""
    
    def test_consumer_login_success(self, client: TestClient, consumer_user):
        """Test consumer can login successfully"""
        response = client.post("/api/auth/login", json={
            "email": "consumer@test.com",
            "password": "Consumer@123"
        })
        
        assert response.status_code == 200
        data = response.json()
        assert data["user"]["username"] == "testconsumer"
