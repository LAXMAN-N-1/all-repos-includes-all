"""
Unit tests for invoices endpoints
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from datetime import datetime, timedelta

from app import models
from app.core import security


class TestInvoicesEndpoints:
    """Test invoice endpoints"""
    
    def test_read_invoices_as_staff(self, client: TestClient, db: Session):
        """Test reading invoices as staff"""
        # Create staff and customer
        staff = models.User(
            email="staff@test.com",
            full_name="Test Staff",
            hashed_password=security.get_password_hash("testpass"),
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(staff)
        
        customer = models.Customer(
            email="customer@test.com",
            name="Test Customer",
            phone="1234567890",
            hashed_password=security.get_password_hash("custpass"),
            customer_type="b2b"
        )
        db.add(customer)
        db.commit()
        db.refresh(customer)
        
        # Create invoice
        invoice = models.Invoice(
            customer_id=customer.id,
            amount_due=1000.0,
            due_date=datetime.utcnow() + timedelta(days=30),
            status="draft"
        )
        db.add(invoice)
        db.commit()
        
        # Login as staff
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "staff@test.com", "password": "testpass"}
        )
        token = login_response.json()["access_token"]
        
        # Get invoices
        response = client.get(
            "/api/v1/invoices/",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        invoices = response.json()
        assert len(invoices) == 1
        assert invoices[0]["amount_due"] == 1000.0
