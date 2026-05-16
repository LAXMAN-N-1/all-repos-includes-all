"""
Event Endpoint Integration Tests
=================================
Tests for /api/events CRUD endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from datetime import datetime, timedelta


class TestCreateEvent:
    """Tests for POST /api/events endpoint"""
    
    def test_create_event_success(
        self, client: TestClient, admin_headers, seed_category, seed_event_type, seed_services
    ):
        """Test admin can create a new event"""
        event_date = (datetime.now() + timedelta(days=60)).isoformat()
        # Use actual service IDs from seed_services fixture
        service_ids = [s.id for s in seed_services] if seed_services else []
        response = client.post("/api/events",
            json={
                "name": "New Test Event",
                "description": "A new test event description",
                "category_id": seed_category.id,
                "event_type_id": seed_event_type.id,
                "event_date": event_date,
                "venue": "Test Venue",
                "city": "Test City",
                "state": "Test State",
                "expected_attendees": 200,
                "budget": 50000,
                "required_services": service_ids
            },
            headers=admin_headers
        )
        
        # Debug: Print error details if status is not 200/201
        if response.status_code not in [200, 201]:
            print(f"DEBUG: Status Code = {response.status_code}")
            print(f"DEBUG: Response = {response.text}")
        
        assert response.status_code in [200, 201], f"Got {response.status_code}: {response.text}"
        data = response.json()
        assert data["name"] == "New Test Event"
    
    def test_create_event_unauthorized(
        self, client: TestClient, seed_category, seed_event_type
    ):
        """Test event creation requires authentication"""
        response = client.post("/api/events", json={
            "name": "Unauthorized Event",
            "category_id": seed_category.id,
            "event_type_id": seed_event_type.id
        })
        
        assert response.status_code == 401


class TestListEvents:
    """Tests for GET /api/events endpoint"""
    
    def test_list_events_success(
        self, client: TestClient, admin_headers, seed_event
    ):
        """Test listing all events"""
        response = client.get("/api/events", headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        
        if isinstance(data, list):
            assert len(data) >= 1
        else:
            assert "items" in data or "data" in data
    
    def test_list_events_with_status_filter(
        self, client: TestClient, admin_headers, seed_event
    ):
        """Test listing events filtered by status"""
        response = client.get(
            "/api/events?status=draft",
            headers=admin_headers
        )
        
        assert response.status_code == 200
    
    def test_list_events_with_category_filter(
        self, client: TestClient, admin_headers, seed_event, seed_category
    ):
        """Test listing events filtered by category"""
        response = client.get(
            f"/api/events?category_id={seed_category.id}",
            headers=admin_headers
        )
        
        assert response.status_code == 200
    
    def test_list_events_unauthorized(self, client: TestClient):
        """Test listing events requires auth"""
        response = client.get("/api/events")
        
        assert response.status_code == 401


class TestGetEventStats:
    """Tests for GET /api/events/stats endpoint"""
    
    def test_get_event_stats_success(
        self, client: TestClient, admin_headers, seed_event
    ):
        """Test getting event statistics"""
        response = client.get("/api/events/stats", headers=admin_headers)
        
        assert response.status_code == 200
        # Stats should return some data structure
        data = response.json()
        assert data is not None


class TestGetEvent:
    """Tests for GET /api/events/{id} endpoint"""
    
    def test_get_event_success(
        self, client: TestClient, admin_headers, seed_event
    ):
        """Test getting single event by ID"""
        response = client.get(
            f"/api/events/{seed_event.id}",
            headers=admin_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == seed_event.id
        assert data["name"] == "Test Event"
    
    def test_get_event_not_found(self, client: TestClient, admin_headers):
        """Test getting non-existent event"""
        response = client.get("/api/events/99999", headers=admin_headers)
        
        assert response.status_code == 404


class TestUpdateEvent:
    """Tests for PUT /api/events/{id} endpoint"""
    
    def test_update_event_success(
        self, client: TestClient, admin_headers, seed_event
    ):
        """Test updating event"""
        response = client.put(
            f"/api/events/{seed_event.id}",
            json={
                "name": "Updated Event Name",
                "description": "Updated description"
            },
            headers=admin_headers
        )
        
        assert response.status_code == 200


class TestDeleteEvent:
    """Tests for DELETE /api/events/{id} endpoint"""
    
    def test_delete_event_success(
        self, client: TestClient, admin_headers, seed_event
    ):
        """Test deleting event (soft delete)"""
        response = client.delete(
            f"/api/events/{seed_event.id}",
            headers=admin_headers
        )
        
        assert response.status_code in [200, 204]


class TestAssignManager:
    """Tests for POST /api/events/{id}/assign-manager endpoint"""
    
    def test_assign_manager_success(
        self, client: TestClient, admin_headers, seed_event, admin_user
    ):
        """Test assigning manager to event"""
        response = client.post(
            f"/api/events/{seed_event.id}/assign-manager?manager_id={admin_user.id}",
            headers=admin_headers
        )
        
        assert response.status_code in [200, 201]
