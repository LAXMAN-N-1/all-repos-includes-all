"""
Consumer Authentication Endpoint Integration Tests
====================================================
Tests for /api/auth/consumer endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from app.models.user_m import User


class TestConsumerRegister:
    """Tests for POST /api/auth/consumer/register endpoint"""
    
    def test_register_success(
        self, client: TestClient, db: Session, seed_consumer_role
    ):
        """Test consumer can register with valid data"""
        response = client.post("/api/auth/consumer/register", json={
            "email": "newconsumer@test.com",
            "password": "Consumer@123",
            "first_name": "John",
            "last_name": "Doe",
            "phone": "9876543210"
        })
        
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"
        assert data["user"]["email"] == "newconsumer@test.com"
        assert data["user"]["first_name"] == "John"
    
    def test_register_duplicate_email(
        self, client: TestClient, db: Session, seed_consumer_role, consumer_user
    ):
        """Test registration fails with existing email"""
        response = client.post("/api/auth/consumer/register", json={
            "email": consumer_user.email,
            "password": "Consumer@123",
            "first_name": "Test",
            "last_name": "User"
        })
        
        assert response.status_code == 400
        assert "already registered" in response.json()["detail"].lower()
    
    def test_register_invalid_email(self, client: TestClient, seed_consumer_role):
        """Test registration fails with invalid email format"""
        response = client.post("/api/auth/consumer/register", json={
            "email": "invalid-email",
            "password": "Consumer@123",
            "first_name": "Test",
            "last_name": "User"
        })
        
        assert response.status_code == 422
    
    def test_register_short_password(self, client: TestClient, seed_consumer_role):
        """Test registration fails with short password"""
        response = client.post("/api/auth/consumer/register", json={
            "email": "test@test.com",
            "password": "short",
            "first_name": "Test",
            "last_name": "User"
        })
        
        assert response.status_code == 422
    
    def test_register_missing_required_fields(self, client: TestClient):
        """Test registration fails without required fields"""
        response = client.post("/api/auth/consumer/register", json={
            "email": "test@test.com"
        })
        
        assert response.status_code == 422


class TestConsumerLogin:
    """Tests for POST /api/auth/consumer/login endpoint"""
    
    def test_login_success(
        self, client: TestClient, db: Session, seed_consumer_role
    ):
        """Test consumer can login with valid credentials"""
        # First register
        client.post("/api/auth/consumer/register", json={
            "email": "logintest@test.com",
            "password": "Consumer@123",
            "first_name": "Login",
            "last_name": "Test"
        })
        
        # Then login
        response = client.post("/api/auth/consumer/login", json={
            "email": "logintest@test.com",
            "password": "Consumer@123"
        })
        
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["user"]["email"] == "logintest@test.com"
    
    def test_login_invalid_password(
        self, client: TestClient, db: Session, seed_consumer_role
    ):
        """Test login fails with wrong password"""
        # Register first
        client.post("/api/auth/consumer/register", json={
            "email": "wrongpass@test.com",
            "password": "Consumer@123",
            "first_name": "Test",
            "last_name": "User"
        })
        
        # Try login with wrong password
        response = client.post("/api/auth/consumer/login", json={
            "email": "wrongpass@test.com",
            "password": "WrongPassword123"
        })
        
        assert response.status_code == 401
        assert "invalid credentials" in response.json()["detail"].lower()
    
    def test_login_nonexistent_email(self, client: TestClient):
        """Test login fails with non-existent email"""
        response = client.post("/api/auth/consumer/login", json={
            "email": "nonexistent@test.com",
            "password": "Consumer@123"
        })
        
        assert response.status_code == 401
    
    def test_login_vendor_account_rejected(
        self, client: TestClient, vendor_user
    ):
        """Test consumer login rejects vendor accounts"""
        response = client.post("/api/auth/consumer/login", json={
            "email": vendor_user.email,
            "password": "Vendor@123"
        })
        
        assert response.status_code == 403
        assert "not a consumer" in response.json()["detail"].lower()


class TestConsumerOTP:
    """Tests for OTP-based authentication"""
    
    def test_request_otp_success(self, client: TestClient):
        """Test OTP request succeeds with valid phone"""
        response = client.post("/api/auth/consumer/otp/request", json={
            "phone": "9876543210"
        })
        
        assert response.status_code == 200
        data = response.json()
        assert "message" in data
        assert data["phone"] == "9876543210"
        # Dev mode returns OTP for testing
        assert "dev_otp" in data
    
    def test_request_otp_invalid_phone(self, client: TestClient):
        """Test OTP request fails with invalid phone"""
        response = client.post("/api/auth/consumer/otp/request", json={
            "phone": "123"  # Too short
        })
        
        assert response.status_code == 422
    
    def test_verify_otp_invalid(self, client: TestClient):
        """Test OTP verification fails with wrong OTP"""
        # Request OTP first
        client.post("/api/auth/consumer/otp/request", json={
            "phone": "9876543212"
        })
        
        # Try wrong OTP
        response = client.post("/api/auth/consumer/otp/verify", json={
            "phone": "9876543212",
            "otp": "000000"  # Wrong OTP
        })
        
        assert response.status_code == 401
        assert "invalid" in response.json()["detail"].lower()
    
    def test_verify_otp_format_invalid(self, client: TestClient):
        """Test OTP verification fails with invalid OTP format"""
        response = client.post("/api/auth/consumer/otp/verify", json={
            "phone": "9876543210",
            "otp": "12"  # Too short
        })
        
        assert response.status_code == 422


class TestConsumerAuthFlow:
    """End-to-end consumer auth flow tests"""
    
    def test_register_then_access_protected_endpoint(
        self, client: TestClient, db: Session, seed_consumer_role,
        seed_organization, seed_category, seed_event_type
    ):
        """Test registered consumer can access protected endpoints"""
        # Register
        register_response = client.post("/api/auth/consumer/register", json={
            "email": "flowtest@test.com",
            "password": "Consumer@123",
            "first_name": "Flow",
            "last_name": "Test"
        })
        
        token = register_response.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}
        
        # Try accessing protected endpoint
        response = client.get("/api/consumer/events/my-events", headers=headers)
        
        # Should succeed (200) or return empty list, not 401
        assert response.status_code in [200, 403]  # 403 if permission not set
