"""
Vendor Order Endpoint Integration Tests
========================================
Tests for /api/vendor/orders endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from app.models.vendor_m import Vendor
from app.models.vendor_order_m import VendorOrder
from datetime import datetime, timedelta
import uuid


@pytest.fixture
def vendor_with_profile(db: Session, vendor_user):
    """Create a vendor profile for the test vendor user"""
    vendor = Vendor(
        user_id=vendor_user.id,
        company_name="Order Test Vendor",
        business_type="Event Services",
        phone="1234567890",
        city="Test City",
        state="Test State",
        status="approved",
        offered_services=[1, 2],
        inactive=False
    )
    db.add(vendor)
    db.commit()
    db.refresh(vendor)
    return vendor


@pytest.fixture
def vendor_order(db: Session, vendor_with_profile, seed_event):
    """Create a single order for testing"""
    order = VendorOrder(
        vendor_id=vendor_with_profile.id,
        event_id=seed_event.id,
        order_ref=f"ORD-{uuid.uuid4().hex[:8].upper()}",
        amount=25000.00,
        status="confirmed",
        confirmed_at=datetime.now(),
        inactive=False
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    return order


@pytest.fixture
def multiple_orders(db: Session, vendor_with_profile, seed_event):
    """Create multiple orders for testing"""
    orders = []
    order_data = [
        ("confirmed", 25000.00, datetime.now() - timedelta(days=1)),
        ("in_progress", 35000.00, datetime.now() - timedelta(days=5)),
        ("completed", 45000.00, datetime.now() - timedelta(days=10)),
        ("confirmed", 15000.00, datetime.now()),
    ]
    
    for status, amount, confirmed_at in order_data:
        order = VendorOrder(
            vendor_id=vendor_with_profile.id,
            event_id=seed_event.id,
            order_ref=f"ORD-{uuid.uuid4().hex[:8].upper()}",
            amount=amount,
            status=status,
            confirmed_at=confirmed_at,
            completed_at=datetime.now() if status == "completed" else None,
            inactive=False
        )
        db.add(order)
        orders.append(order)
    
    db.commit()
    for o in orders:
        db.refresh(o)
    return orders


class TestGetOrderStats:
    """Tests for GET /api/vendor/orders/stats endpoint"""
    
    def test_order_stats_success(
        self, client: TestClient, vendor_headers, vendor_with_profile, multiple_orders
    ):
        """Test getting order statistics"""
        response = client.get("/api/vendor/orders/stats", headers=vendor_headers)
        
        assert response.status_code == 200
        data = response.json()
        # Check for expected stats fields
        assert isinstance(data, dict)
    
    def test_order_stats_empty(
        self, client: TestClient, vendor_headers, vendor_with_profile
    ):
        """Test order stats when no orders exist"""
        response = client.get("/api/vendor/orders/stats", headers=vendor_headers)
        
        assert response.status_code == 200
    
    def test_order_stats_unauthorized(self, client: TestClient):
        """Test order stats requires authentication"""
        response = client.get("/api/vendor/orders/stats")
        
        assert response.status_code == 401


class TestListOrders:
    """Tests for GET /api/vendor/orders/ endpoint"""
    
    def test_list_orders_success(
        self, client: TestClient, vendor_headers, vendor_with_profile, vendor_order
    ):
        """Test listing vendor orders"""
        response = client.get("/api/vendor/orders/", headers=vendor_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) >= 1
    
    def test_list_orders_empty(
        self, client: TestClient, vendor_headers, vendor_with_profile
    ):
        """Test listing orders when none exist"""
        response = client.get("/api/vendor/orders/", headers=vendor_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) == 0
    
    def test_list_orders_filter_by_status(
        self, client: TestClient, vendor_headers, vendor_with_profile, multiple_orders
    ):
        """Test filtering orders by status"""
        response = client.get(
            "/api/vendor/orders/?status=confirmed",
            headers=vendor_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        # Should only return confirmed orders
        for order in data:
            assert order.get("status") == "confirmed"
    
    def test_list_orders_pagination(
        self, client: TestClient, vendor_headers, vendor_with_profile, multiple_orders
    ):
        """Test pagination for orders"""
        response = client.get(
            "/api/vendor/orders/?skip=1&limit=2",
            headers=vendor_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) <= 2
    
    def test_list_orders_unauthorized(self, client: TestClient):
        """Test listing orders requires authentication"""
        response = client.get("/api/vendor/orders/")
        
        assert response.status_code == 401


class TestGetOrderDetail:
    """Tests for GET /api/vendor/orders/{id} endpoint"""
    
    def test_get_order_detail_success(
        self, client: TestClient, vendor_headers, vendor_with_profile, vendor_order
    ):
        """Test getting order details"""
        response = client.get(
            f"/api/vendor/orders/{vendor_order.id}",
            headers=vendor_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data.get("order_ref") == vendor_order.order_ref
    
    def test_get_order_detail_not_found(
        self, client: TestClient, vendor_headers, vendor_with_profile
    ):
        """Test getting non-existent order"""
        response = client.get(
            "/api/vendor/orders/99999",
            headers=vendor_headers
        )
        
        assert response.status_code == 404
    
    def test_get_order_detail_unauthorized(self, client: TestClient):
        """Test order details require authentication"""
        response = client.get("/api/vendor/orders/1")
        
        assert response.status_code == 401


class TestUpdateOrderStatus:
    """Tests for PUT /api/vendor/orders/{id}/status endpoint"""
    
    def test_update_status_success(
        self, client: TestClient, vendor_headers, vendor_with_profile, vendor_order
    ):
        """Test updating order status"""
        response = client.put(
            f"/api/vendor/orders/{vendor_order.id}/status",
            json={"status": "in_progress"},
            headers=vendor_headers
        )
        
        assert response.status_code == 200
    
    def test_update_status_to_completed(
        self, client: TestClient, vendor_headers, vendor_with_profile, vendor_order
    ):
        """Test marking order as completed"""
        response = client.put(
            f"/api/vendor/orders/{vendor_order.id}/status",
            json={"status": "completed"},
            headers=vendor_headers
        )
        
        assert response.status_code == 200
    
    def test_update_status_not_found(
        self, client: TestClient, vendor_headers, vendor_with_profile
    ):
        """Test updating non-existent order"""
        response = client.put(
            "/api/vendor/orders/99999/status",
            json={"status": "in_progress"},
            headers=vendor_headers
        )
        
        assert response.status_code == 404
    
    def test_update_status_unauthorized(self, client: TestClient):
        """Test updating order status requires authentication"""
        response = client.put(
            "/api/vendor/orders/1/status",
            json={"status": "in_progress"}
        )
        
        assert response.status_code == 401


class TestOrderAccessControl:
    """Tests for order access control"""
    
    def test_cannot_view_other_vendor_orders(
        self, client: TestClient, db: Session, vendor_headers, 
        seed_vendor, seed_event
    ):
        """Test vendor cannot see another vendor's orders"""
        # Create order for a different vendor (seed_vendor)
        other_vendor, other_user = seed_vendor
        other_order = VendorOrder(
            vendor_id=other_vendor.id,
            event_id=seed_event.id,
            order_ref=f"ORD-OTHER-{uuid.uuid4().hex[:8].upper()}",
            amount=50000.00,
            status="confirmed",
            confirmed_at=datetime.now(),
            inactive=False
        )
        db.add(other_order)
        db.commit()
        db.refresh(other_order)
        
        # Try to access the other vendor's order
        response = client.get(
            f"/api/vendor/orders/{other_order.id}",
            headers=vendor_headers
        )
        
        # Should fail - either 403 or 404 depending on implementation
        assert response.status_code in [403, 404]
    
    def test_cannot_update_other_vendor_order(
        self, client: TestClient, db: Session, vendor_headers,
        seed_vendor, seed_event
    ):
        """Test vendor cannot update another vendor's order"""
        # Create order for a different vendor
        other_vendor, other_user = seed_vendor
        other_order = VendorOrder(
            vendor_id=other_vendor.id,
            event_id=seed_event.id,
            order_ref=f"ORD-OTHER2-{uuid.uuid4().hex[:8].upper()}",
            amount=50000.00,
            status="confirmed",
            confirmed_at=datetime.now(),
            inactive=False
        )
        db.add(other_order)
        db.commit()
        db.refresh(other_order)
        
        # Try to update the other vendor's order
        response = client.put(
            f"/api/vendor/orders/{other_order.id}/status",
            json={"status": "in_progress"},
            headers=vendor_headers
        )
        
        # Should fail
        assert response.status_code in [403, 404]
