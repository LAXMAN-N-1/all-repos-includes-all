"""
Category Endpoint Integration Tests
====================================
Tests for /api/categories CRUD endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


class TestCreateCategory:
    """Tests for POST /api/categories endpoint"""
    
    def test_create_category_success(self, client: TestClient, admin_headers):
        """Test admin can create a new category"""
        import uuid
        unique_code = f"UNIQUE_{uuid.uuid4().hex[:6].upper()}"
        response = client.post("/api/categories",
            json={
                "name": f"Unique Test Category {unique_code}",
                "code": unique_code,
                "description": "Test category for integration tests",
                "icon": "🎪",
                "color": "teal"
            },
            headers=admin_headers
        )
        
        assert response.status_code in [200, 201]
        data = response.json()
        assert data["code"] == unique_code
    
    def test_create_category_unauthorized(self, client: TestClient):
        """Test category creation requires authentication"""
        response = client.post("/api/categories", json={
            "name": "Unauthorized Category",
            "code": "UNAUTH"
        })
        
        assert response.status_code == 401
    
    def test_create_category_duplicate_code(
        self, client: TestClient, admin_headers, seed_category
    ):
        """Test creating category with duplicate code fails"""
        response = client.post("/api/categories",
            json={
                "name": "Another Category",
                "code": "TEST_CAT",  # Same as seed_category
                "description": "Duplicate test"
            },
            headers=admin_headers
        )
        
        # Should fail with conflict or validation error
        assert response.status_code in [400, 409, 422, 500]


class TestListCategories:
    """Tests for GET /api/categories endpoint"""
    
    def test_list_categories_success(
        self, client: TestClient, admin_headers, seed_category
    ):
        """Test listing all categories"""
        response = client.get("/api/categories", headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        
        if isinstance(data, list):
            assert len(data) >= 1
        else:
            assert "items" in data or "data" in data
    
    def test_list_categories_unauthorized(self, client: TestClient):
        """Test listing categories requires auth"""
        response = client.get("/api/categories")
        
        assert response.status_code == 401


class TestGetCategory:
    """Tests for GET /api/categories/{id} endpoint"""
    
    def test_get_category_success(
        self, client: TestClient, admin_headers, seed_category
    ):
        """Test getting single category by ID"""
        response = client.get(
            f"/api/categories/{seed_category.id}",
            headers=admin_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == seed_category.id
    
    def test_get_category_not_found(self, client: TestClient, admin_headers):
        """Test getting non-existent category"""
        response = client.get("/api/categories/99999", headers=admin_headers)
        
        assert response.status_code == 404


class TestUpdateCategory:
    """Tests for PUT /api/categories/{id} endpoint"""
    
    def test_update_category_success(
        self, client: TestClient, admin_headers, seed_category
    ):
        """Test updating category"""
        response = client.put(
            f"/api/categories/{seed_category.id}",
            json={
                "name": "Updated Category",
                "description": "Updated description"
            },
            headers=admin_headers
        )
        
        assert response.status_code == 200


class TestDeleteCategory:
    """Tests for DELETE /api/categories/{id} endpoint"""
    
    def test_delete_category_success(
        self, client: TestClient, admin_headers, seed_category
    ):
        """Test deleting category (soft delete)"""
        response = client.delete(
            f"/api/categories/{seed_category.id}",
            headers=admin_headers
        )
        
        assert response.status_code in [200, 204]
