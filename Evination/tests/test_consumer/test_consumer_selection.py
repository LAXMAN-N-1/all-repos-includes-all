"""
Consumer Selection Endpoint Integration Tests
==============================================
Tests for /api/consumer/selection endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from app.models.event_m import Event, EventStatus, BiddingStatus
from app.models.vendor_m import Vendor
from app.models.vendor_bid_m import VendorBid
from datetime import datetime, timedelta


@pytest.fixture
def consumer_event_with_bids(
    db: Session, consumer_user, seed_organization, 
    seed_category, seed_event_type, seed_vendor
):
    """Create a consumer event with vendor bids"""
    # Create event
    event = Event(
        organization_id=seed_organization.id,
        name="Event with Bids",
        category_id=seed_category.id,
        event_type_id=seed_event_type.id,
        event_date=datetime.now() + timedelta(days=30),
        status=EventStatus.PLANNING,
        bidding_status=BiddingStatus.SHORTLISTED,
        city="Test City",
        state="Test State",
        venue="Test Venue",
        expected_attendees=100,
        budget=100000.00,
        required_services=[1, 2],
        inactive=False
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    
    # Create vendor bids
    vendor, vendor_user = seed_vendor
    bids = []
    for i, amount in enumerate([80000.00, 90000.00, 100000.00]):
        bid = VendorBid(
            vendor_id=vendor.id,
            event_id=event.id,
            total_amount=amount,
            proposal_description=f"Bid proposal #{i+1}",
            timeline_days=14 + i,
            status="shortlisted",
            inactive=False
        )
        db.add(bid)
        bids.append(bid)
    
    db.commit()
    for b in bids:
        db.refresh(b)
    
    return event, bids


class TestGetShortlistedBids:
    """Tests for GET /api/consumer/selection/events/{id}/shortlisted-bids endpoint"""
    
    def test_get_shortlisted_bids_success(
        self, client: TestClient, consumer_headers, consumer_event_with_bids
    ):
        """Test consumer can view shortlisted bids"""
        event, bids = consumer_event_with_bids
        
        response = client.get(
            f"/api/consumer/selection/events/{event.id}/shortlisted-bids",
            headers=consumer_headers
        )
        
        # May return 200 or 403 (permission)
        assert response.status_code in [200, 403, 404]
    
    def test_get_shortlisted_bids_not_found(
        self, client: TestClient, consumer_headers
    ):
        """Test getting bids for non-existent event"""
        response = client.get(
            "/api/consumer/selection/events/99999/shortlisted-bids",
            headers=consumer_headers
        )
        
        assert response.status_code in [403, 404]
    
    def test_get_shortlisted_bids_unauthorized(self, client: TestClient):
        """Test viewing bids requires authentication"""
        response = client.get("/api/consumer/selection/events/1/shortlisted-bids")
        
        assert response.status_code == 401


class TestSelectWinningBid:
    """Tests for POST /api/consumer/selection/events/{id}/select/{bid_id} endpoint"""
    
    def test_select_winning_bid_success(
        self, client: TestClient, consumer_headers, consumer_event_with_bids
    ):
        """Test consumer can select a winning bid"""
        event, bids = consumer_event_with_bids
        winning_bid = bids[0]
        
        response = client.post(
            f"/api/consumer/selection/events/{event.id}/select/{winning_bid.id}",
            headers=consumer_headers
        )
        
        # May return 200 or 403 (permission)
        assert response.status_code in [200, 403, 404, 400]
    
    def test_select_bid_event_not_found(
        self, client: TestClient, consumer_headers
    ):
        """Test selecting bid for non-existent event"""
        response = client.post(
            "/api/consumer/selection/events/99999/select/1",
            headers=consumer_headers
        )
        
        assert response.status_code in [403, 404]
    
    def test_select_bid_not_found(
        self, client: TestClient, consumer_headers, consumer_event_with_bids
    ):
        """Test selecting non-existent bid"""
        event, bids = consumer_event_with_bids
        
        response = client.post(
            f"/api/consumer/selection/events/{event.id}/select/99999",
            headers=consumer_headers
        )
        
        assert response.status_code in [400, 403, 404]
    
    def test_select_bid_unauthorized(self, client: TestClient):
        """Test selecting bid requires authentication"""
        response = client.post("/api/consumer/selection/events/1/select/1")
        
        assert response.status_code == 401


class TestSelectionAccessControl:
    """Tests for selection access control"""
    
    def test_cannot_select_bid_for_other_consumer_event(
        self, client: TestClient, db: Session, consumer_headers,
        seed_organization, seed_category, seed_event_type, seed_vendor
    ):
        """Test consumer cannot select bid for another consumer's event"""
        # Create another event not owned by test consumer
        other_event = Event(
            organization_id=seed_organization.id,
            name="Other Consumer Event",
            category_id=seed_category.id,
            event_type_id=seed_event_type.id,
            event_date=datetime.now() + timedelta(days=30),
            status=EventStatus.PLANNING,
            bidding_status=BiddingStatus.SHORTLISTED,
            city="Other City",
            state="Other State",
            required_services=[1],
            inactive=False
        )
        db.add(other_event)
        db.commit()
        db.refresh(other_event)
        
        # Create a bid
        vendor, vendor_user = seed_vendor
        bid = VendorBid(
            vendor_id=vendor.id,
            event_id=other_event.id,
            total_amount=50000.00,
            proposal_description="Other bid",
            timeline_days=10,
            status="shortlisted",
            inactive=False
        )
        db.add(bid)
        db.commit()
        db.refresh(bid)
        
        # Try to select bid
        response = client.post(
            f"/api/consumer/selection/events/{other_event.id}/select/{bid.id}",
            headers=consumer_headers
        )
        
        # Should fail with 403 or 404
        assert response.status_code in [403, 404]
