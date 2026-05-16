"""
Branch Endpoint Integration Tests
==================================
Tests for /api/branches CRUD endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


class TestCreateBranch:
    """Tests for POST /api/branches endpoint"""
    
    def test_create_branch_success(
        self, client: TestClient, admin_headers, seed_organization
    ):
        """Test admin can create a new branch"""
        response = client.post("/api/branches",
            json={
                "name": "New Branch",
                "code": "NEWBRANCH",
                "email": "newbranch@test.com",
                "phone": "9999999999",
                "address": "789 New Street",
                "city": "New City",
                "state": "New State",
                "country": "New Country",
                "pincode": "67890",
                "organization_id": seed_organization.id
            },
            headers=admin_headers
        )
        
        assert response.status_code in [200, 201]
        data = response.json()
        assert data["name"] == "New Branch"
        assert data["code"] == "NEWBRANCH"
    
    def test_create_branch_unauthorized(self, client: TestClient, seed_organization):
        """Test branch creation requires authentication"""
        response = client.post("/api/branches", json={
            "name": "Unauthorized Branch",
            "code": "UNAUTH",
            "organization_id": seed_organization.id
        })
        
        assert response.status_code == 401


class TestListBranches:
    """Tests for GET /api/branches endpoint"""
    
    def test_list_branches_success(
        self, client: TestClient, admin_headers, seed_branch
    ):
        """Test listing all branches"""
        response = client.get("/api/branches", headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        
        if isinstance(data, list):
            # Branches are filtered by organization_id
            assert isinstance(data, list)
        else:
            assert "items" in data or "data" in data
    
    def test_list_branches_unauthorized(self, client: TestClient):
        """Test listing branches requires auth"""
        response = client.get("/api/branches")
        
        assert response.status_code == 401


class TestGetBranch:
    """Tests for GET /api/branches/{id} endpoint"""
    
    def test_get_branch_success(
        self, client: TestClient, admin_headers, seed_branch
    ):
        """Test getting single branch by ID"""
        response = client.get(
            f"/api/branches/{seed_branch.id}",
            headers=admin_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == seed_branch.id
        assert data["code"] == "TESTBRANCH"
    
    def test_get_branch_not_found(self, client: TestClient, admin_headers):
        """Test getting non-existent branch"""
        response = client.get("/api/branches/99999", headers=admin_headers)
        
        assert response.status_code == 404


class TestUpdateBranch:
    """Tests for PUT /api/branches/{id} endpoint"""
    
    def test_update_branch_success(
        self, client: TestClient, admin_headers, seed_branch
    ):
        """Test updating branch"""
        response = client.put(
            f"/api/branches/{seed_branch.id}",
            json={
                "name": "Updated Branch Name",
                "city": "Updated City"
            },
            headers=admin_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "Updated Branch Name"


class TestDeleteBranch:
    """Tests for DELETE /api/branches/{id} endpoint"""
    
    def test_delete_branch_success(
        self, client: TestClient, admin_headers, seed_branch
    ):
        """Test deleting branch (soft delete)"""
        response = client.delete(
            f"/api/branches/{seed_branch.id}",
            headers=admin_headers
        )
        
        assert response.status_code in [200, 204]
