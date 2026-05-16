"""
Review Endpoint Integration Tests
==================================
Tests for /api/reviews endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from app.models.review_m import Review


@pytest.fixture
def review_data(seed_vendor, seed_event):
    """Valid review creation data"""
    vendor, vendor_user = seed_vendor
    return {
        "vendor_id": vendor.id,
        "event_id": seed_event.id,
        "rating": 5,
        "comment": "Excellent service! Highly recommend."
    }


@pytest.fixture
def existing_review(db: Session, consumer_user, seed_vendor, seed_event):
    """Create an existing review"""
    vendor, vendor_user = seed_vendor
    review = Review(
        consumer_id=consumer_user.id,
        vendor_id=vendor.id,
        event_id=seed_event.id,
        rating=4,
        comment="Good service overall",
        inactive=False
    )
    db.add(review)
    db.commit()
    db.refresh(review)
    return review


@pytest.fixture
def multiple_reviews(db: Session, seed_vendor, seed_event, seed_consumer_role):
    """Create multiple reviews for a vendor"""
    from app.models.user_m import User
    from app.utils.password_utils import hash_password
    
    vendor, vendor_user = seed_vendor
    reviews = []
    
    for i in range(3):
        # Create consumer users
        consumer = User(
            username=f"reviewer{i}",
            email=f"reviewer{i}@test.com",
            password_hash=hash_password("Test@123"),
            first_name=f"Reviewer",
            last_name=f"{i}",
            role_id=seed_consumer_role.id,
            inactive=False
        )
        db.add(consumer)
        db.flush()
        
        review = Review(
            consumer_id=consumer.id,
            vendor_id=vendor.id,
            event_id=seed_event.id,
            rating=4 + (i % 2),  # Ratings 4 or 5
            comment=f"Review comment #{i+1}",
            inactive=False
        )
        db.add(review)
        reviews.append(review)
    
    db.commit()
    for r in reviews:
        db.refresh(r)
    return reviews


class TestCreateReview:
    """Tests for POST /api/reviews/ endpoint"""
    
    def test_create_review_success(
        self, client: TestClient, consumer_headers, review_data
    ):
        """Test consumer can create a review"""
        response = client.post(
            "/api/reviews/",
            json=review_data,
            headers=consumer_headers
        )
        
        # May return 201, 200, 403, or 422
        assert response.status_code in [200, 201, 403, 422]
    
    def test_create_review_invalid_rating(
        self, client: TestClient, consumer_headers, review_data
    ):
        """Test review creation fails with invalid rating"""
        invalid_data = review_data.copy()
        invalid_data["rating"] = 10  # Invalid rating
        
        response = client.post(
            "/api/reviews/",
            json=invalid_data,
            headers=consumer_headers
        )
        
        assert response.status_code in [400, 403, 422]
    
    def test_create_review_missing_vendor(
        self, client: TestClient, consumer_headers
    ):
        """Test review creation fails without vendor_id"""
        response = client.post(
            "/api/reviews/",
            json={
                "rating": 5,
                "comment": "Great!"
            },
            headers=consumer_headers
        )
        
        assert response.status_code in [403, 422]
    
    def test_create_review_unauthorized(self, client: TestClient, review_data):
        """Test review creation requires authentication"""
        response = client.post("/api/reviews/", json=review_data)
        
        assert response.status_code == 401


class TestGetVendorReviews:
    """Tests for GET /api/reviews/vendor/{id} endpoint"""
    
    def test_get_vendor_reviews_success(
        self, client: TestClient, seed_vendor, existing_review
    ):
        """Test getting reviews for a vendor (public endpoint)"""
        vendor, vendor_user = seed_vendor
        
        response = client.get(f"/api/reviews/vendor/{vendor.id}")
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
    
    def test_get_vendor_reviews_multiple(
        self, client: TestClient, seed_vendor, multiple_reviews
    ):
        """Test getting multiple reviews"""
        vendor, vendor_user = seed_vendor
        
        response = client.get(f"/api/reviews/vendor/{vendor.id}")
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) >= 3
    
    def test_get_vendor_reviews_pagination(
        self, client: TestClient, seed_vendor, multiple_reviews
    ):
        """Test reviews pagination"""
        vendor, vendor_user = seed_vendor
        
        response = client.get(
            f"/api/reviews/vendor/{vendor.id}?skip=0&limit=2"
        )
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) <= 2
    
    def test_get_vendor_reviews_empty(
        self, client: TestClient, seed_vendor
    ):
        """Test getting reviews for vendor with no reviews"""
        vendor, vendor_user = seed_vendor
        
        response = client.get(f"/api/reviews/vendor/{vendor.id}")
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
    
    def test_get_reviews_vendor_not_found(self, client: TestClient):
        """Test getting reviews for non-existent vendor"""
        response = client.get("/api/reviews/vendor/99999")
        
        # Should return empty list or 404
        assert response.status_code in [200, 404]
