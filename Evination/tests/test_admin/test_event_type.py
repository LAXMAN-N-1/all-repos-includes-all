"""
Event Type Endpoint Integration Tests
======================================
Tests for /api/event-types CRUD endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


class TestCreateEventType:
    """Tests for POST /api/event-types endpoint"""
    
    def test_create_event_type_success(
        self, client: TestClient, admin_headers, seed_category
    ):
        """Test admin can create a new event type"""
        import uuid
        unique_code = f"EVT_{uuid.uuid4().hex[:6].upper()}"
        response = client.post("/api/event-types",
            json={
                "category_id": seed_category.id,
                "name": f"Test Event Type {unique_code}",
                "code": unique_code,
                "color": "green"
            },
            headers=admin_headers
        )
        
        assert response.status_code in [200, 201]
        data = response.json()
        assert data["code"] == unique_code
    
    def test_create_event_type_unauthorized(
        self, client: TestClient, seed_category
    ):
        """Test event type creation requires authentication"""
        response = client.post("/api/event-types", json={
            "category_id": seed_category.id,
            "name": "Unauthorized Type",
            "code": "UNAUTH"
        })
        
        assert response.status_code == 401
    
    def test_create_event_type_invalid_category(
        self, client: TestClient, admin_headers
    ):
        """Test creating event type with invalid category fails"""
        response = client.post("/api/event-types",
            json={
                "category_id": 99999,  # Non-existent category
                "name": "Invalid Category Type",
                "code": "INVALID_CAT"
            },
            headers=admin_headers
        )
        
        # Should fail with not found or validation error
        assert response.status_code in [400, 404, 422, 500]


class TestListEventTypes:
    """Tests for GET /api/event-types endpoint"""
    
    def test_list_event_types_success(
        self, client: TestClient, admin_headers, seed_event_type
    ):
        """Test listing all event types"""
        response = client.get("/api/event-types", headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        
        if isinstance(data, list):
            assert len(data) >= 1
        else:
            assert "items" in data or "data" in data
    
    def test_list_event_types_by_category(
        self, client: TestClient, admin_headers, seed_event_type, seed_category
    ):
        """Test listing event types filtered by category"""
        response = client.get(
            f"/api/event-types?category_id={seed_category.id}",
            headers=admin_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        if isinstance(data, list):
            assert len(data) >= 1
    
    def test_list_event_types_unauthorized(self, client: TestClient):
        """Test listing event types requires auth"""
        response = client.get("/api/event-types")
        
        assert response.status_code == 401


class TestGetEventType:
    """Tests for GET /api/event-types/{id} endpoint"""
    
    def test_get_event_type_success(
        self, client: TestClient, admin_headers, seed_event_type
    ):
        """Test getting single event type by ID"""
        response = client.get(
            f"/api/event-types/{seed_event_type.id}",
            headers=admin_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == seed_event_type.id
    
    def test_get_event_type_not_found(self, client: TestClient, admin_headers):
        """Test getting non-existent event type"""
        response = client.get("/api/event-types/99999", headers=admin_headers)
        
        assert response.status_code == 404


class TestUpdateEventType:
    """Tests for PUT /api/event-types/{id} endpoint"""
    
    def test_update_event_type_success(
        self, client: TestClient, admin_headers, seed_event_type
    ):
        """Test updating event type"""
        response = client.put(
            f"/api/event-types/{seed_event_type.id}",
            json={
                "name": "Updated Event Type",
                "color": "red"
            },
            headers=admin_headers
        )
        
        assert response.status_code == 200


class TestDeleteEventType:
    """Tests for DELETE /api/event-types/{id} endpoint"""
    
    def test_delete_event_type_success(
        self, client: TestClient, admin_headers, seed_event_type
    ):
        """Test deleting event type (soft delete)"""
        response = client.delete(
            f"/api/event-types/{seed_event_type.id}",
            headers=admin_headers
        )
        
        assert response.status_code in [200, 204]
