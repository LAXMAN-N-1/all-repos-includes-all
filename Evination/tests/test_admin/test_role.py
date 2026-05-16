"""
Role Endpoint Integration Tests
================================
Tests for /api/roles CRUD endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


class TestCreateRole:
    """Tests for POST /api/roles endpoint"""
    
    def test_create_role_success(self, client: TestClient, admin_headers):
        """Test admin can create a new role"""
        response = client.post("/api/roles",
            json={
                "name": "Event Manager",
                "code": "EVENT_MGR",
                "description": "Manages events"
            },
            headers=admin_headers
        )
        
        assert response.status_code in [200, 201]
        data = response.json()
        assert data["name"] == "Event Manager"
        assert data["code"] == "EVENT_MGR"
    
    def test_create_role_unauthorized(self, client: TestClient):
        """Test role creation requires authentication"""
        response = client.post("/api/roles", json={
            "name": "Unauthorized Role",
            "code": "UNAUTH"
        })
        
        assert response.status_code == 401


class TestListRoles:
    """Tests for GET /api/roles endpoint"""
    
    def test_list_roles_success(self, client: TestClient, admin_headers, seed_role):
        """Test listing all roles"""
        response = client.get("/api/roles", headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        
        if isinstance(data, list):
            assert len(data) >= 1
        else:
            assert "items" in data or "data" in data


class TestGetRole:
    """Tests for GET /api/roles/{id} endpoint"""
    
    def test_get_role_success(self, client: TestClient, admin_headers, seed_role):
        """Test getting single role by ID"""
        response = client.get(f"/api/roles/{seed_role.id}", headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == seed_role.id
    
    def test_get_role_not_found(self, client: TestClient, admin_headers):
        """Test getting non-existent role"""
        response = client.get("/api/roles/99999", headers=admin_headers)
        
        assert response.status_code == 404


class TestUpdateRole:
    """Tests for PUT /api/roles/{id} endpoint"""
    
    def test_update_role_success(self, client: TestClient, admin_headers, seed_role):
        """Test updating role"""
        response = client.put(
            f"/api/roles/{seed_role.id}",
            json={"name": "Updated Admin", "description": "Updated description"},
            headers=admin_headers
        )
        
        assert response.status_code == 200


class TestDeleteRole:
    """Tests for DELETE /api/roles/{id} endpoint"""
    
    def test_delete_role_success(self, client: TestClient, admin_headers, seed_role):
        """Test deleting role"""
        response = client.delete(f"/api/roles/{seed_role.id}", headers=admin_headers)
        
        assert response.status_code in [200, 204]
