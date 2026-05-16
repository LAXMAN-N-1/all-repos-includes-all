"""
Unit tests for orders endpoints
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app import models
from app.core import security
from app.features.orders.models.order import OrderStatus


class TestOrdersEndpoints:
    """Test order endpoints"""
    
    def test_create_order_as_partner(self, client: TestClient, db: Session):
        """Test creating an order as a verified partner"""
        # Create verified partner
        partner = models.Customer(
            email="partner@test.com",
            name="Test Partner",
            phone="1234567890",
            hashed_password=security.get_password_hash("partnerpass"),
            customer_type="b2b",
            is_active=True,
            is_verified=True,
            status="verified",
            credit_limit=10000.0,
            current_balance=0.0
        )
        db.add(partner)
        
        # Create product
        product = models.Product(
            name="Test Product",
            sku="TEST001",
            price=100.0,
            wholesale_price=80.0,
            unit="lb",
            stock_quantity=100,
            min_order_quantity=1,
            is_active=True
        )
        db.add(product)
        db.commit()
        db.refresh(partner)
        db.refresh(product)
        
        # Login as partner
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "partner@test.com", "password": "partnerpass"}
        )
        token = login_response.json()["access_token"]
        
        # Create order
        order_data = {
            "customer_id": partner.id,
            "items": [
                {
                    "product_id": product.id,
                    "quantity": 10
                }
            ],
            "notes": "Test order"
        }
        
        response = client.post(
            "/api/v1/orders/",
            json=order_data,
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "pending"
        assert data["total_amount"] == 800.0  # 10 * 80 (wholesale price)
    
    def test_create_order_unverified_partner_fails(self, client: TestClient, db: Session):
        """Test that unverified partners cannot create orders"""
        # Create unverified partner
        partner = models.Customer(
            email="unverified@test.com",
            name="Unverified Partner",
            phone="1234567890",
            hashed_password=security.get_password_hash("pass"),
            customer_type="b2b",
            is_active=True,
            is_verified=False,
            status="submitted"
        )
        db.add(partner)
        
        product = models.Product(
            name="Test Product",
            sku="TEST001",
            price=100.0,
            unit="lb",
            stock_quantity=100
        )
        db.add(product)
        db.commit()
        db.refresh(partner)
        db.refresh(product)
        
        # Login
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "unverified@test.com", "password": "pass"}
        )
        token = login_response.json()["access_token"]
        
        # Try to create order
        order_data = {
            "customer_id": partner.id,
            "items": [{"product_id": product.id, "quantity": 5}]
        }
        
        response = client.post(
            "/api/v1/orders/",
            json=order_data,
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 403
        assert "pending verification" in response.json()["detail"].lower()
    
    def test_create_order_exceeds_credit_limit(self, client: TestClient, db: Session):
        """Test order creation fails when credit limit is exceeded"""
        # Create partner with low credit limit
        partner = models.Customer(
            email="partner@test.com",
            name="Test Partner",
            phone="1234567890",
            hashed_password=security.get_password_hash("pass"),
            customer_type="b2b",
            is_active=True,
            is_verified=True,
            status="verified",
            credit_limit=100.0,
            current_balance=0.0
        )
        db.add(partner)
        
        product = models.Product(
            name="Expensive Product",
            sku="EXP001",
            price=200.0,
            wholesale_price=150.0,
            unit="lb",
            stock_quantity=100,
            min_order_quantity=1
        )
        db.add(product)
        db.commit()
        db.refresh(partner)
        db.refresh(product)
        
        # Login
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "partner@test.com", "password": "pass"}
        )
        token = login_response.json()["access_token"]
        
        # Try to create order that exceeds credit limit
        order_data = {
            "customer_id": partner.id,
            "items": [{"product_id": product.id, "quantity": 10}]  # 10 * 150 = 1500
        }
        
        response = client.post(
            "/api/v1/orders/",
            json=order_data,
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 403
        assert "credit limit" in response.json()["detail"].lower()
    
    def test_read_orders_partner_sees_only_own(self, client: TestClient, db: Session):
        """Test that partners can only see their own orders"""
        # Create two partners
        partner1 = models.Customer(
            email="partner1@test.com",
            name="Partner 1",
            phone="1111111111",
            hashed_password=security.get_password_hash("pass1"),
            customer_type="b2b",
            is_active=True,
            is_verified=True,
            status="verified"
        )
        partner2 = models.Customer(
            email="partner2@test.com",
            name="Partner 2",
            phone="2222222222",
            hashed_password=security.get_password_hash("pass2"),
            customer_type="b2b",
            is_active=True,
            is_verified=True,
            status="verified"
        )
        db.add_all([partner1, partner2])
        db.commit()
        db.refresh(partner1)
        db.refresh(partner2)
        
        # Create orders for each
        order1 = models.Order(
            customer_id=partner1.id,
            total_amount=100.0,
            status=OrderStatus.PENDING
        )
        order2 = models.Order(
            customer_id=partner2.id,
            total_amount=200.0,
            status=OrderStatus.PENDING
        )
        db.add_all([order1, order2])
        db.commit()
        
        # Login as partner1
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "partner1@test.com", "password": "pass1"}
        )
        token = login_response.json()["access_token"]
        
        # Get orders
        response = client.get(
            "/api/v1/orders/",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        orders = response.json()
        assert len(orders) == 1
        assert orders[0]["customer_id"] == partner1.id
    
    def test_update_order_status(self, client: TestClient, db: Session):
        """Test updating order status"""
        # Create staff and order
        staff = models.User(
            email="staff@test.com",
            full_name="Test Staff",
            hashed_password=security.get_password_hash("staffpass"),
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(staff)
        
        partner = models.Customer(
            email="partner@test.com",
            name="Test Partner",
            phone="1234567890",
            hashed_password=security.get_password_hash("pass"),
            customer_type="b2b",
            is_verified=True,
            status="verified",
            current_balance=0.0,
            credit_limit=1000.0
        )
        db.add(partner)
        db.commit()
        db.refresh(partner)
        
        order = models.Order(
            customer_id=partner.id,
            total_amount=500.0,
            status=OrderStatus.PENDING
        )
        db.add(order)
        db.commit()
        db.refresh(order)
        
        # Login as staff
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "staff@test.com", "password": "staffpass"}
        )
        token = login_response.json()["access_token"]
        
        # Update order status
        update_data = {"status": "confirmed"}
        response = client.put(
            f"/api/v1/orders/{order.id}",
            json=update_data,
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "confirmed"
        
        # Verify customer balance updated
        db.refresh(partner)
        assert partner.current_balance == 500.0

    def test_create_order_invalid_location(self, client: TestClient, db: Session):
        """Test that an order fails if the location doesn't belong to the customer"""
        # 1. Create two partners
        p1 = models.Customer(
            email="p1@test.com", name="P1", customer_type="b2b", 
            is_verified=True, status="verified", is_active=True,
            hashed_password=security.get_password_hash("pass")
        )
        p2 = models.Customer(
            email="p2@test.com", name="P2", customer_type="b2b",
            is_verified=True, status="verified", is_active=True,
            hashed_password=security.get_password_hash("pass")
        )
        db.add_all([p1, p2])
        db.flush()

        # 2. Create location for P2
        loc2 = models.Location(name="P2 Warehouse", customer_id=p2.id)
        db.add(loc2)
        
        # 3. Create product
        prod = models.Product(name="P", sku="P", price=10.0, stock_quantity=100)
        db.add(prod)
        db.commit()

        # 4. Login as P1
        login_res = client.post("/api/v1/auth/login", data={"username": "p1@test.com", "password": "pass"})
        token = login_res.json()["access_token"]

        # 5. Try to create order for P1 but using P2's location
        order_data = {
            "customer_id": p1.id,
            "location_id": loc2.id, # INVALID for P1
            "items": [{"product_id": prod.id, "quantity": 1}]
        }
        
        response = client.post(
            "/api/v1/orders/",
            json=order_data,
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 400
        assert "invalid delivery location for this customer" in response.json()["detail"].lower()
