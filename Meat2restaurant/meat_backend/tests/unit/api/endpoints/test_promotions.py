"""
Unit tests for promotions endpoints
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from datetime import datetime, timedelta

from app import models
from app.core import security


class TestPromotionsEndpoints:
    """Test promotions endpoints"""
    
    def test_get_active_promotions(self, client: TestClient, db: Session):
        """Test getting active promotions"""
        # Create staff
        staff = models.User(
            email="staff@test.com",
            full_name="Test Staff",
            hashed_password=security.get_password_hash("testpass"),
            role="admin",
            is_active=True
        )
        db.add(staff)
        
        # Create promotion
        promotion = models.Promotion(
            name="Test Promo",
            code="TESTPROMO",
            discount_value=10.0,
            start_date=datetime.utcnow() - timedelta(days=1),
            end_date=datetime.utcnow() + timedelta(days=30),
            is_active=True
        )
        db.add(promotion)
        db.commit()
        
        # Login
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "staff@test.com", "password": "testpass"}
        )
        token = login_response.json()["access_token"]
        
        # Get promotions
        response = client.get(
            "/api/v1/promotions/",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        promotions = response.json()
        assert len(promotions) >= 1
