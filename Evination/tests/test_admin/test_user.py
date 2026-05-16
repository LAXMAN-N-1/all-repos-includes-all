"""
User Endpoint Integration Tests
================================
Tests for /api/users CRUD endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


class TestCreateUser:
    """Tests for POST /api/users endpoint"""
    
    def test_create_user_success(self, client: TestClient, admin_headers, seed_role):
        """Test admin can create a new user"""
        response = client.post("/api/users",
            json={
                "username": "newuser",
                "email": "newuser@test.com",
                "password": "NewUser@123",
                "first_name": "New",
                "last_name": "User",
                "role_id": seed_role.id
            },
            headers=admin_headers
        )
        
        assert response.status_code in [200, 201]
        data = response.json()
        assert data["username"] == "newuser"
        assert data["email"] == "newuser@test.com"
    
    def test_create_user_duplicate_username(
        self, client: TestClient, admin_headers, admin_user, seed_role
    ):
        """Test creating user with duplicate username fails"""
        response = client.post("/api/users",
            json={
                "username": "testadmin",  # Already exists
                "email": "different@test.com",
                "password": "Test@123",
                "role_id": seed_role.id
            },
            headers=admin_headers
        )
        
        assert response.status_code in [400, 409, 422]
    
    def test_create_user_duplicate_email(
        self, client: TestClient, admin_headers, admin_user, seed_role
    ):
        """Test creating user with duplicate email fails"""
        response = client.post("/api/users",
            json={
                "username": "differentuser",
                "email": "admin@test.com",  # Already exists
                "password": "Test@123",
                "role_id": seed_role.id
            },
            headers=admin_headers
        )
        
        assert response.status_code in [400, 409, 422]
    
    def test_create_user_unauthorized(self, client: TestClient, seed_role):
        """Test user creation requires authentication"""
        response = client.post("/api/users", json={
            "username": "unauthorized",
            "email": "unauth@test.com",
            "password": "Test@123",
            "role_id": seed_role.id
        })
        
        assert response.status_code == 401


class TestListUsers:
    """Tests for GET /api/users endpoint"""
    
    def test_list_users_success(self, client: TestClient, admin_headers, admin_user):
        """Test listing all users"""
        response = client.get("/api/users", headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        
        if isinstance(data, list):
            assert len(data) >= 1
        else:
            assert "items" in data or "data" in data


class TestGetUser:
    """Tests for GET /api/users/{id} endpoint"""
    
    def test_get_user_success(self, client: TestClient, admin_headers, admin_user):
        """Test getting single user by ID"""
        response = client.get(f"/api/users/{admin_user.id}", headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == admin_user.id
        assert data["username"] == "testadmin"
    
    def test_get_user_not_found(self, client: TestClient, admin_headers):
        """Test getting non-existent user"""
        response = client.get("/api/users/99999", headers=admin_headers)
        
        assert response.status_code == 404


class TestUpdateUser:
    """Tests for PUT /api/users/{id} endpoint"""
    
    def test_update_user_success(self, client: TestClient, admin_headers, admin_user):
        """Test updating user"""
        response = client.put(
            f"/api/users/{admin_user.id}",
            json={"first_name": "Updated", "last_name": "Admin"},
            headers=admin_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["first_name"] == "Updated"


class TestDeleteUser:
    """Tests for DELETE /api/users/{id} endpoint"""
    
    def test_delete_user_success(
        self, client: TestClient, admin_headers, db: Session, seed_role, seed_organization
    ):
        """Test deleting a user (not the admin user)"""
        from tests.conftest import create_test_user
        
        # Create a user to delete with same organization as admin
        user_to_delete = create_test_user(
            db=db,
            username="todelete",
            email="delete@test.com",
            password="Delete@123",
            role_id=seed_role.id,
            organization_id=seed_organization.id
        )
        
        response = client.delete(
            f"/api/users/{user_to_delete.id}",
            headers=admin_headers
        )
        
        assert response.status_code in [200, 204]

