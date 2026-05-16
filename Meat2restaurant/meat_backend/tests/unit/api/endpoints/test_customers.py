"""
Unit tests for customers endpoints
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app import models
from app.core import security


class TestCustomersEndpoints:
    """Test customer endpoints"""
    
    def test_read_customers_as_staff(self, client: TestClient, db: Session):
        """Test staff can read all customers"""
        # Create staff
        staff = models.User(
            email="staff@test.com",
            full_name="Test Staff",
            hashed_password=security.get_password_hash("testpass"),
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(staff)
        
        # Create customers
        customer1 = models.Customer(
            email="cust1@test.com",
            name="Customer 1",
            phone="1111111111",
            hashed_password=security.get_password_hash("pass1"),
            customer_type="b2b"
        )
        customer2 = models.Customer(
            email="cust2@test.com",
            name="Customer 2",
            phone="2222222222",
            hashed_password=security.get_password_hash("pass2"),
            customer_type="b2b"
        )
        db.add_all([customer1, customer2])
        db.commit()
        
        # Login as staff
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "staff@test.com", "password": "testpass"}
        )
        token = login_response.json()["access_token"]
        
        # Get customers
        response = client.get(
            "/api/v1/customers/",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        customers = response.json()
        assert len(customers) == 2
    
    def test_read_customers_as_partner_only_self(self, client: TestClient, db: Session):
        """Test partner can only read their own data"""
        # Create partners
        partner1 = models.Customer(
            email="partner1@test.com",
            name="Partner 1",
            phone="1111111111",
            hashed_password=security.get_password_hash("pass1"),
            customer_type="b2b",
            is_active=True
        )
        partner2 = models.Customer(
            email="partner2@test.com",
            name="Partner 2",
            phone="2222222222",
            hashed_password=security.get_password_hash("pass2"),
            customer_type="b2b",
            is_active=True
        )
        db.add_all([partner1, partner2])
        db.commit()
        
        # Login as partner1
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "partner1@test.com", "password": "pass1"}
        )
        token = login_response.json()["access_token"]
        
        # Get customers - should only see self
        response = client.get(
            "/api/v1/customers/",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        customers = response.json()
        assert len(customers) == 1
        assert customers[0]["email"] == "partner1@test.com"
    
    def test_create_customer_as_superuser(self, client: TestClient, db: Session):
        """Test creating customer as superuser"""
        # Create superuser
        superuser = models.User(
            email="super@test.com",
            full_name="Super User",
            hashed_password=security.get_password_hash("superpass"),
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(superuser)
        db.commit()
        
        # Login
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "super@test.com", "password": "superpass"}
        )
        token = login_response.json()["access_token"]
        
        # Create customer
        customer_data = {
            "name": "New Customer",
            "email": "newcust@test.com",
            "phone": "9999999999",
            "password": "custpass123",
            "customer_type": "b2b",
            "address": "123 Test St"
        }
        
        response = client.post(
            "/api/v1/customers/",
            json=customer_data,
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["email"] == "newcust@test.com"
        assert data["name"] == "New Customer"
    
    def test_verify_partner(self, client: TestClient, db: Session):
        """Test verifying a partner"""
        # Create superuser and unverified partner
        superuser = models.User(
            email="super@test.com",
            full_name="Super User",
            hashed_password=security.get_password_hash("superpass"),
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(superuser)
        
        partner = models.Customer(
            email="partner@test.com",
            name="Unverified Partner",
            phone="1234567890",
            hashed_password=security.get_password_hash("partnerpass"),
            customer_type="b2b",
            is_verified=False,
            status="submitted"
        )
        db.add(partner)
        db.commit()
        db.refresh(partner)
        
        # Login as superuser
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "super@test.com", "password": "superpass"}
        )
        token = login_response.json()["access_token"]
        
        # Verify partner
        response = client.post(
            f"/api/v1/customers/{partner.id}/verify",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["is_verified"] == True
        assert data["status"] == "verified"
        assert data["is_active"] == True
    
    def test_suspend_partner(self, client: TestClient, db: Session):
        """Test suspending a partner"""
        # Create superuser and active partner
        superuser = models.User(
            email="super@test.com",
            full_name="Super User",
            hashed_password=security.get_password_hash("superpass"),
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(superuser)
        
        partner = models.Customer(
            email="partner@test.com",
            name="Active Partner",
            phone="1234567890",
            hashed_password=security.get_password_hash("partnerpass"),
            customer_type="b2b",
            is_verified=True,
            is_active=True,
            status="verified"
        )
        db.add(partner)
        db.commit()
        db.refresh(partner)
        
        # Login as superuser
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "super@test.com", "password": "superpass"}
        )
        token = login_response.json()["access_token"]
        
        # Suspend partner
        response = client.post(
            f"/api/v1/customers/{partner.id}/suspend",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["is_verified"] == False
        assert data["status"] == "suspended"
        assert data["is_active"] == False
    
    def test_delete_customer(self, client: TestClient, db: Session):
        """Test deleting a customer"""
        # Create superuser and customer
        superuser = models.User(
            email="super@test.com",
            full_name="Super User",
            hashed_password=security.get_password_hash("superpass"),
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(superuser)
        
        customer = models.Customer(
            email="delete@test.com",
            name="Delete Me",
            phone="1234567890",
            hashed_password=security.get_password_hash("pass"),
            customer_type="b2b"
        )
        db.add(customer)
        db.commit()
        db.refresh(customer)
        
        # Login
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "super@test.com", "password": "superpass"}
        )
        token = login_response.json()["access_token"]
        
        # Delete customer
        response = client.delete(
            f"/api/v1/customers/{customer.id}",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        
        # Verify deletion
        deleted = db.query(models.Customer).filter(models.Customer.id == customer.id).first()
        assert deleted is None
