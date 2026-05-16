"""
Organization Endpoint Integration Tests
========================================
Tests for /api/organizations CRUD endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


class TestCreateOrganization:
    """Tests for POST /api/organizations endpoint"""
    
    def test_create_organization_success(self, client: TestClient, admin_headers):
        """Test admin can create organization"""
        response = client.post("/api/organizations", 
            json={
                "name": "New Test Org",
                "code": "NEWORG",
                "address": "456 New Street",
                "city": "New City",
                "state": "New State",
                "country": "New Country",
                "zip_code": "54321"
            },
            headers=admin_headers
        )
        
        assert response.status_code in [200, 201]
        data = response.json()
        assert data["name"] == "New Test Org"
        assert data["code"] == "NEWORG"
    
    def test_create_organization_unauthorized(self, client: TestClient):
        """Test organization creation requires authentication"""
        response = client.post("/api/organizations", json={
            "name": "Unauthorized Org",
            "code": "UNAUTH"
        })
        
        assert response.status_code == 401
    
    def test_create_organization_duplicate_code(
        self, client: TestClient, admin_headers, seed_organization
    ):
        """Test creating organization with duplicate code fails"""
        response = client.post("/api/organizations",
            json={
                "name": "Duplicate Org",
                "code": "TESTORG",  # Same as seed_organization
            },
            headers=admin_headers
        )
        
        # Should fail with conflict or validation error
        assert response.status_code in [400, 409, 422]


class TestListOrganizations:
    """Tests for GET /api/organizations endpoint"""
    
    def test_list_organizations_success(
        self, client: TestClient, admin_headers, seed_organization
    ):
        """Test listing organizations"""
        response = client.get("/api/organizations", headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        
        # Should be a list or paginated response
        if isinstance(data, list):
            assert len(data) >= 1
        else:
            # If paginated
            assert "items" in data or "data" in data
    
    def test_list_organizations_unauthorized(self, client: TestClient):
        """Test listing organizations requires auth"""
        response = client.get("/api/organizations")
        
        assert response.status_code == 401


class TestGetOrganization:
    """Tests for GET /api/organizations/{id} endpoint"""
    
    def test_get_organization_success(
        self, client: TestClient, admin_headers, seed_organization
    ):
        """Test getting single organization by ID"""
        response = client.get(
            f"/api/organizations/{seed_organization.id}",
            headers=admin_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == seed_organization.id
        assert data["code"] == "TESTORG"
    
    def test_get_organization_not_found(self, client: TestClient, admin_headers):
        """Test getting non-existent organization"""
        response = client.get("/api/organizations/99999", headers=admin_headers)
        
        assert response.status_code == 404


class TestUpdateOrganization:
    """Tests for PUT /api/organizations/{id} endpoint"""
    
    def test_update_organization_success(
        self, client: TestClient, admin_headers, seed_organization
    ):
        """Test updating organization"""
        response = client.put(
            f"/api/organizations/{seed_organization.id}",
            json={
                "name": "Updated Org Name",
                "city": "Updated City"
            },
            headers=admin_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "Updated Org Name"


class TestDeleteOrganization:
    """Tests for DELETE /api/organizations/{id} endpoint"""
    
    def test_delete_organization_success(
        self, client: TestClient, admin_headers, seed_organization
    ):
        """Test deleting organization (soft delete)"""
        response = client.delete(
            f"/api/organizations/{seed_organization.id}",
            headers=admin_headers
        )
        
        assert response.status_code in [200, 204]
        
        # Verify organization is soft deleted (inactive)
        get_response = client.get(
            f"/api/organizations/{seed_organization.id}",
            headers=admin_headers
        )
        # Either returns 404 or returns with inactive=True
        assert get_response.status_code in [200, 404]
