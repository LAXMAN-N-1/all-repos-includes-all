"""
Unit tests for products endpoints
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app import models
from app.core import security


class TestProductsEndpoints:
    """Test product endpoints"""
    
    def test_read_products_authenticated(self, client: TestClient, db: Session):
        """Test reading products with authentication"""
        # Create staff user and product
        hashed_password = security.get_password_hash("testpass")
        staff = models.User(
            email="staff@test.com",
            full_name="Test Staff",
            hashed_password=hashed_password,
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(staff)
        
        product = models.Product(
            name="Test Product",
            sku="TEST001",
            price=100.0,
            wholesale_price=80.0,
            unit="lb",
            stock_quantity=50,
            is_active=True
        )
        db.add(product)
        db.commit()
        
        # Login to get token
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "staff@test.com", "password": "testpass"}
        )
        token = login_response.json()["access_token"]
        
        # Get products
        response = client.get(
            "/api/v1/products/",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        products = response.json()
        assert len(products) == 1
        assert products[0]["name"] == "Test Product"
        assert products[0]["sku"] == "TEST001"
    
    def test_create_product_as_admin(self, client: TestClient, db: Session):
        """Test creating a product as admin"""
        # Create admin user
        hashed_password = security.get_password_hash("adminpass")
        admin = models.User(
            email="admin@test.com",
            full_name="Admin User",
            hashed_password=hashed_password,
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(admin)
        db.commit()
        
        # Login
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "admin@test.com", "password": "adminpass"}
        )
        token = login_response.json()["access_token"]
        
        # Create product
        product_data = {
            "name": "New Product",
            "sku": "NEW001",
            "price": 150.0,
            "wholesale_price": 120.0,
            "unit": "lb",
            "stock_quantity": 100,
            "is_active": True,
            "min_order_quantity": 1
        }
        
        response = client.post(
            "/api/v1/products/",
            json=product_data,
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "New Product"
        assert data["sku"] == "NEW001"
        assert data["price"] == 150.0
    
    def test_create_product_duplicate_sku(self, client: TestClient, db: Session):
        """Test creating product with duplicate SKU"""
        # Create admin and existing product
        hashed_password = security.get_password_hash("adminpass")
        admin = models.User(
            email="admin@test.com",
            full_name="Admin User",
            hashed_password=hashed_password,
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(admin)
        
        existing_product = models.Product(
            name="Existing Product",
            sku="DUP001",
            price=100.0,
            unit="lb",
            stock_quantity=50
        )
        db.add(existing_product)
        db.commit()
        
        # Login
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "admin@test.com", "password": "adminpass"}
        )
        token = login_response.json()["access_token"]
        
        # Try to create product with same SKU
        product_data = {
            "name": "Duplicate Product",
            "sku": "DUP001",
            "price": 150.0,
            "unit": "lb",
            "stock_quantity": 100
        }
        
        response = client.post(
            "/api/v1/products/",
            json=product_data,
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 400
        assert "already exists" in response.json()["detail"]
    
    def test_get_product_by_id(self, client: TestClient, db: Session):
        """Test getting a specific product by ID"""
        # Create staff and product
        hashed_password = security.get_password_hash("testpass")
        staff = models.User(
            email="staff@test.com",
            full_name="Test Staff",
            hashed_password=hashed_password,
            role="staff",
            is_active=True
        )
        db.add(staff)
        
        product = models.Product(
            name="Specific Product",
            sku="SPEC001",
            price=200.0,
            unit="lb",
            stock_quantity=30
        )
        db.add(product)
        db.commit()
        db.refresh(product)
        
        # Login
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "staff@test.com", "password": "testpass"}
        )
        token = login_response.json()["access_token"]
        
        # Get product by ID
        response = client.get(
            f"/api/v1/products/{product.id}",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "Specific Product"
        assert data["sku"] == "SPEC001"
    
    def test_get_nonexistent_product(self, client: TestClient, db: Session):
        """Test getting a product that doesn't exist"""
        # Create staff
        hashed_password = security.get_password_hash("testpass")
        staff = models.User(
            email="staff@test.com",
            full_name="Test Staff",
            hashed_password=hashed_password,
            role="staff",
            is_active=True
        )
        db.add(staff)
        db.commit()
        
        # Login
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "staff@test.com", "password": "testpass"}
        )
        token = login_response.json()["access_token"]
        
        # Try to get non-existent product
        response = client.get(
            "/api/v1/products/99999",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 404
        assert "not found" in response.json()["detail"]
    
    def test_delete_product_as_superuser(self, client: TestClient, db: Session):
        """Test deleting a product as superuser"""
        # Create superuser and product
        hashed_password = security.get_password_hash("superpass")
        superuser = models.User(
            email="super@test.com",
            full_name="Super User",
            hashed_password=hashed_password,
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(superuser)
        
        product = models.Product(
            name="Delete Me",
            sku="DEL001",
            price=100.0,
            unit="lb",
            stock_quantity=10
        )
        db.add(product)
        db.commit()
        db.refresh(product)
        
        # Login
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "super@test.com", "password": "superpass"}
        )
        token = login_response.json()["access_token"]
        
        # Delete product
        response = client.delete(
            f"/api/v1/products/{product.id}",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        
        # Verify deletion
        deleted_product = db.query(models.Product).filter(models.Product.id == product.id).first()
        assert deleted_product is None
