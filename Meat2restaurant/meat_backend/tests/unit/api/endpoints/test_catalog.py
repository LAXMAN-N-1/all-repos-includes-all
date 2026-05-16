"""
Unit tests for catalog endpoints
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app import models
from app.core import security


class TestCatalogEndpoints:
    """Test catalog endpoints"""
    
    def test_get_categories(self, client: TestClient, db: Session):
        """Test getting categories"""
        # Create staff
        staff = models.User(
            email="staff@test.com",
            full_name="Test Staff",
            hashed_password=security.get_password_hash("testpass"),
            role="admin",
            is_active=True
        )
        db.add(staff)
        
        # Create categories
        category = models.Category(
            name="Meat",
            description="Fresh meat products"
        )
        db.add(category)
        db.commit()
        
        # Login
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "staff@test.com", "password": "testpass"}
        )
        token = login_response.json()["access_token"]
        
        # Get categories
        response = client.get(
            "/api/v1/catalog/categories",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        assert response.status_code == 200
        categories = response.json()
        assert len(categories) == 1
        assert categories[0]["name"] == "Meat"

    def test_attributes_crud(self, client: TestClient, db: Session):
        """Test attributes CRUD operations"""
        # 1. Create superuser
        superuser = models.User(
            email="admin@test.com",
            full_name="Test Admin",
            hashed_password=security.get_password_hash("adminpass"),
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(superuser)
        db.commit()

        # Login as superuser
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "admin@test.com", "password": "adminpass"}
        )
        token = login_response.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # 2. CREATE Attribute
        create_data = {"name": "Test Attribute", "is_active": True}
        response = client.post("/api/v1/catalog/attributes", json=create_data, headers=headers)
        assert response.status_code == 200
        attr = response.json()
        attr_id = attr["id"]
        assert attr["name"] == "Test Attribute"

        # 3. READ Attribute (Detail)
        response = client.get(f"/api/v1/catalog/attributes/{attr_id}", headers=headers)
        assert response.status_code == 200
        assert response.json()["name"] == "Test Attribute"

        # 4. READ Attributes (List)
        response = client.get("/api/v1/catalog/attributes", headers=headers)
        assert response.status_code == 200
        assert len(response.json()) >= 1

        # 5. UPDATE Attribute
        update_data = {"name": "Updated Attribute"}
        response = client.put(f"/api/v1/catalog/attributes/{attr_id}", json=update_data, headers=headers)
        assert response.status_code == 200
        assert response.json()["name"] == "Updated Attribute"

        # 6. DELETE Attribute
        response = client.delete(f"/api/v1/catalog/attributes/{attr_id}", headers=headers)
        assert response.status_code == 200
        
        # Verify deletion
        response = client.get(f"/api/v1/catalog/attributes/{attr_id}", headers=headers)
        assert response.status_code == 404
    def test_categories_hierarchy(self, client: TestClient, db: Session):
        """Test hierarchical categories with parent_id"""
        # 1. Create superuser
        superuser = models.User(
            email="admin_hier@test.com",
            full_name="Test Admin",
            hashed_password=security.get_password_hash("adminpass"),
            role="admin",
            is_active=True,
            is_superuser=True
        )
        db.add(superuser)
        db.commit()

        # Login as superuser
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "admin_hier@test.com", "password": "adminpass"}
        )
        token = login_response.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # 2. CREATE Parent Category
        parent_data = {"name": "Meat", "description": "All meat products"}
        response = client.post("/api/v1/catalog/categories", json=parent_data, headers=headers)
        assert response.status_code == 200
        parent_cat = response.json()
        parent_id = parent_cat["id"]

        # 3. CREATE Subcategory
        child_data = {"name": "Chicken", "description": "Fresh chicken", "parent_id": parent_id}
        response = client.post("/api/v1/catalog/categories", json=child_data, headers=headers)
        assert response.status_code == 200
        child_cat = response.json()
        assert child_cat["parent_id"] == parent_id

        # 4. READ Subcategory
        response = client.get(f"/api/v1/catalog/categories/{child_cat['id']}", headers=headers)
        assert response.status_code == 200
        assert response.json()["parent_id"] == parent_id

        # 5. TEST INVALID: Category cannot be its own parent (UPDATE)
        update_data = {"parent_id": child_cat['id']}
        response = client.put(f"/api/v1/catalog/categories/{child_cat['id']}", json=update_data, headers=headers)
        assert response.status_code == 400
        assert "Category cannot be its own parent" in response.json()["detail"]

        # 6. TEST INVALID: Parent category not found (UPDATE)
        update_data = {"parent_id": 99999}
        response = client.put(f"/api/v1/catalog/categories/{child_cat['id']}", json=update_data, headers=headers)
        assert response.status_code == 400
        assert "Parent category not found" in response.json()["detail"]
