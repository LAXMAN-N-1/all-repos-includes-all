"""
Unit tests for users endpoints
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app import models
from app.core import security


class TestUsersEndpoints:
    """Test user endpoints"""
    
    def test_create_user_as_superuser(self, client: TestClient, db: Session):
        """Test creating a user as superuser"""
        # Create superuser
        superuser = models.User(
            email="super@test.com",
            full_name="Super User",
            hashed_password=security.get_password_hash("superpass"),
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(superuser)
        db.commit()
        
        # Login
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "super@test.com", "password": "superpass"}
        )
        token = login_response.json()["access_token"]
        
        # Create user
        user_data = {
            "email": "newstaff@test.com",
            "full_name": "New Staff",
            "password": "newpass123",
            "role": "staff",
            "is_active": True
        }
        
        response = client.post(
            "/api/v1/users/",
            json=user_data,
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["email"] == "newstaff@test.com"
        assert data["role"] == "staff"
    
    def test_read_users_list(self, client: TestClient, db: Session):
        """Test reading users list"""
        # Create superuser and staff
        superuser = models.User(
            email="super@test.com",
            full_name="Super User",
            hashed_password=security.get_password_hash("superpass"),
            role="admin",
            is_active=True,
            is_superuser=True
        )
        staff = models.User(
            email="staff@test.com",
            full_name="Staff User",
            hashed_password=security.get_password_hash("staffpass"),
            role="staff",
            is_active=True
        )
        db.add_all([superuser, staff])
        db.commit()
        
        # Login as superuser
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "super@test.com", "password": "superpass"}
        )
        token = login_response.json()["access_token"]
        
        # Get users
        response = client.get(
            "/api/v1/users/",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        users = response.json()
        assert len(users) == 2
