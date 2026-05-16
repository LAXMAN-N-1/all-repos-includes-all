"""
Admin Vendor Management Endpoint Integration Tests
===================================================
Tests for /api/admin/vendors endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


class TestListPendingVendors:
    """Tests for GET /api/admin/vendors/pending endpoint"""
    
    def test_list_pending_vendors_success(
        self, client: TestClient, admin_headers, seed_pending_vendor
    ):
        """Test admin can list pending vendor registrations"""
        response = client.get("/api/admin/vendors/pending", headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        
        if isinstance(data, list):
            assert len(data) >= 1
            # Verify the pending vendor is in the list
            pending_ids = [v.get("id") for v in data]
            pending_vendor, _ = seed_pending_vendor
            assert pending_vendor.id in pending_ids
    
    def test_list_pending_vendors_unauthorized(self, client: TestClient):
        """Test listing pending vendors requires authentication"""
        response = client.get("/api/admin/vendors/pending")
        
        assert response.status_code == 401


class TestGetVendorDetails:
    """Tests for GET /api/admin/vendors/{vendor_id} endpoint"""
    
    def test_get_vendor_details_success(
        self, client: TestClient, admin_headers, seed_vendor
    ):
        """Test admin can get vendor details"""
        vendor, _ = seed_vendor
        response = client.get(
            f"/api/admin/vendors/{vendor.id}",
            headers=admin_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == vendor.id
    
    def test_get_vendor_details_not_found(self, client: TestClient, admin_headers):
        """Test getting non-existent vendor returns 404"""
        response = client.get("/api/admin/vendors/99999", headers=admin_headers)
        
        assert response.status_code == 404


class TestApproveVendor:
    """Tests for PUT /api/admin/vendors/{vendor_id}/approve endpoint"""
    
    def test_approve_vendor_success(
        self, client: TestClient, admin_headers, seed_pending_vendor
    ):
        """Test admin can approve a pending vendor"""
        pending_vendor, _ = seed_pending_vendor
        response = client.put(
            f"/api/admin/vendors/{pending_vendor.id}/approve",
            headers=admin_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        # Vendor status should be approved
        assert data.get("status") == "approved" or "success" in str(data).lower()
    
    def test_approve_vendor_not_found(self, client: TestClient, admin_headers):
        """Test approving non-existent vendor returns 404"""
        response = client.put(
            "/api/admin/vendors/99999/approve",
            headers=admin_headers
        )
        
        assert response.status_code == 404


class TestRejectVendor:
    """Tests for PUT /api/admin/vendors/{vendor_id}/reject endpoint"""
    
    def test_reject_vendor_success(
        self, client: TestClient, admin_headers, seed_pending_vendor
    ):
        """Test admin can reject a pending vendor"""
        pending_vendor, _ = seed_pending_vendor
        response = client.put(
            f"/api/admin/vendors/{pending_vendor.id}/reject",
            json={"reason": "Incomplete documentation"},
            headers=admin_headers
        )
        
        assert response.status_code == 200
    
    def test_reject_vendor_without_reason(
        self, client: TestClient, admin_headers, seed_pending_vendor
    ):
        """Test rejecting vendor without reason fails validation"""
        pending_vendor, _ = seed_pending_vendor
        response = client.put(
            f"/api/admin/vendors/{pending_vendor.id}/reject",
            json={},  # No reason provided
            headers=admin_headers
        )
        
        # Should fail validation
        assert response.status_code == 422


class TestListAllVendors:
    """Tests for GET /api/admin/vendors endpoint"""
    
    def test_list_all_vendors_success(
        self, client: TestClient, admin_headers, seed_vendor
    ):
        """Test admin can list all vendors"""
        response = client.get("/api/admin/vendors", headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
    
    def test_list_vendors_with_status_filter(
        self, client: TestClient, admin_headers, seed_vendor
    ):
        """Test listing vendors with status filter"""
        response = client.get(
            "/api/admin/vendors?status=approved",
            headers=admin_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        # All returned vendors should have approved status
        for vendor in data:
            assert vendor.get("status") == "approved"
    
    def test_list_vendors_unauthorized(self, client: TestClient):
        """Test listing vendors requires authentication"""
        response = client.get("/api/admin/vendors")
        
        assert response.status_code == 401
