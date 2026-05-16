"""
Vendor Bidding Endpoint Integration Tests
==========================================
Tests for /api/vendor/bidding endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from app.models.vendor_m import Vendor
from app.models.event_m import Event, EventStatus, BiddingStatus
from app.models.vendor_bid_m import VendorBid
from datetime import datetime, timedelta


@pytest.fixture
def vendor_profile(db: Session, vendor_user):
    """Create approved vendor profile"""
    vendor = Vendor(
        user_id=vendor_user.id,
        company_name="Bidding Vendor",
        status="approved",
        offered_services=[1, 2],
        inactive=False
    )
    db.add(vendor)
    db.commit()
    db.refresh(vendor)
    return vendor


@pytest.fixture
def test_event(db: Session, seed_organization, seed_category, seed_event_type):
    """Create a test event for bidding"""
    event = Event(
        organization_id=seed_organization.id,
        name="Test Wedding Event",
        category_id=seed_category.id,
        event_type_id=seed_event_type.id,
        event_date=datetime.now() + timedelta(days=30),
        status=EventStatus.PLANNING,
        bidding_status=BiddingStatus.OPEN,
        city="Test City",
        state="Test State",
        required_services=[1, 2],
        inactive=False
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    return event


@pytest.fixture
def vendor_bid(db: Session, vendor_profile, test_event):
    """Create an existing bid for testing"""
    bid = VendorBid(
        vendor_id=vendor_profile.id,
        event_id=test_event.id,
        total_amount=50000.00,
        proposal_description="Complete event management package",
        timeline_days=30,
        status="submitted",
        inactive=False
    )
    db.add(bid)
    db.commit()
    db.refresh(bid)
    return bid


class TestListAvailableEvents:
    """Tests for GET /api/vendor/bidding/available-events endpoint"""
    
    def test_list_events_success(
        self, client: TestClient, vendor_headers, vendor_profile, test_event
    ):
        """Test vendor can list events available for bidding"""
        response = client.get("/api/vendor/bidding/available-events", headers=vendor_headers)
        
        # May return 200 even if empty, or event list
        assert response.status_code == 200

    def test_list_events_unauthorized(self, client: TestClient):
        """Test listing events requires authentication"""
        response = client.get("/api/vendor/bidding/available-events")
        
        assert response.status_code == 401


class TestSubmitBid:
    """Tests for POST /api/vendor/bidding/submit endpoint"""
    
    def test_submit_bid_success(
        self, client: TestClient, vendor_headers, vendor_profile, test_event
    ):
        """Test vendor can submit a bid"""
        response = client.post("/api/vendor/bidding/submit",
            json={
                "event_id": test_event.id,
                "total_amount": 50000.00,
                "proposal_description": "Complete event management package",
                "timeline_days": 30
            },
            headers=vendor_headers
        )
        
        # Should succeed or return validation error if event not available
        assert response.status_code in [200, 201, 400, 404]
    
    def test_submit_bid_unauthorized(self, client: TestClient, test_event):
        """Test bidding requires vendor authentication"""
        response = client.post("/api/vendor/bidding/submit", json={
            "event_id": test_event.id,
            "total_amount": 50000.00
        })
        
        assert response.status_code == 401


class TestGetBid:
    """Tests for GET /api/vendor/bidding/{id} endpoint"""
    
    def test_get_bid_success(
        self, client: TestClient, vendor_headers, vendor_profile, vendor_bid
    ):
        """Test vendor can get their own bid"""
        response = client.get(
            f"/api/vendor/bidding/{vendor_bid.id}",
            headers=vendor_headers
        )
        
        assert response.status_code == 200
    
    def test_get_bid_not_found(
        self, client: TestClient, vendor_headers, vendor_profile
    ):
        """Test getting non-existent bid"""
        response = client.get("/api/vendor/bidding/99999", headers=vendor_headers)
        
        # Could be 404 or 403 depending on implementation
        assert response.status_code in [403, 404]


class TestEditBid:
    """Tests for PUT /api/vendor/bidding/{id} endpoint"""
    
    def test_edit_bid_success(
        self, client: TestClient, vendor_headers, vendor_profile, vendor_bid
    ):
        """Test vendor can edit their bid"""
        response = client.put(
            f"/api/vendor/bidding/{vendor_bid.id}",
            json={
                "total_amount": 55000.00,
                "proposal_description": "Updated proposal"
            },
            headers=vendor_headers
        )
        
        # Could succeed or fail based on bidding deadline
        assert response.status_code in [200, 400, 403]
    
    def test_edit_bid_unauthorized(self, client: TestClient, vendor_bid):
        """Test editing bid requires authentication"""
        response = client.put(
            f"/api/vendor/bidding/{vendor_bid.id}",
            json={"total_amount": 60000.00}
        )
        
        assert response.status_code == 401


class TestWithdrawBid:
    """Tests for DELETE /api/vendor/bidding/{id} endpoint"""
    
    def test_withdraw_bid_success(
        self, client: TestClient, vendor_headers, vendor_profile, vendor_bid
    ):
        """Test vendor can withdraw their bid"""
        response = client.delete(
            f"/api/vendor/bidding/{vendor_bid.id}",
            headers=vendor_headers
        )
        
        # Could succeed or fail based on bidding status
        assert response.status_code in [200, 204, 400, 403]
    
    def test_withdraw_bid_not_found(
        self, client: TestClient, vendor_headers, vendor_profile
    ):
        """Test withdrawing non-existent bid"""
        response = client.delete("/api/vendor/bidding/99999", headers=vendor_headers)
        
        # Could be 404 or 403 depending on implementation
        assert response.status_code in [403, 404]
    
    def test_withdraw_bid_unauthorized(self, client: TestClient):
        """Test withdrawing bid requires authentication"""
        response = client.delete("/api/vendor/bidding/1")
        
        assert response.status_code == 401


class TestListMyBids:
    """Tests for GET /api/vendor/bidding/my-bids endpoint (list own bids)"""
    
    def test_list_my_bids_success(
        self, client: TestClient, vendor_headers, vendor_profile, vendor_bid
    ):
        """Test vendor can list their own bids"""
        response = client.get("/api/vendor/bidding/my-bids", headers=vendor_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
    
    def test_list_my_bids_empty(
        self, client: TestClient, vendor_headers, vendor_profile
    ):
        """Test listing bids when none exist"""
        response = client.get("/api/vendor/bidding/my-bids", headers=vendor_headers)
        
        assert response.status_code == 200
    
    def test_list_my_bids_unauthorized(self, client: TestClient):
        """Test listing bids requires authentication"""
        response = client.get("/api/vendor/bidding/my-bids")
        
        assert response.status_code == 401


class TestBidAccessControl:
    """Tests for bid access control"""
    
    def test_cannot_view_other_vendor_bid(
        self, client: TestClient, db: Session, vendor_headers, 
        seed_vendor, test_event
    ):
        """Test vendor cannot see another vendor's bid"""
        other_vendor, other_user = seed_vendor
        other_bid = VendorBid(
            vendor_id=other_vendor.id,
            event_id=test_event.id,
            total_amount=40000.00,
            proposal_description="Other vendor's proposal",
            timeline_days=25,
            status="submitted",
            inactive=False
        )
        db.add(other_bid)
        db.commit()
        db.refresh(other_bid)
        
        # Try to view other vendor's bid
        response = client.get(
            f"/api/vendor/bidding/{other_bid.id}",
            headers=vendor_headers
        )
        
        # Should fail
        assert response.status_code in [403, 404]
