import sys
from pathlib import Path
import time
from datetime import datetime

# Add the parent directory to sys.path to allow importing from 'app'
sys.path.append(str(Path(__file__).resolve().parents[1]))

from app.db.session import SessionLocal
from app.models.user import User
from app.models.product import Product

def verify_timestamps():
    db = SessionLocal()
    try:
        print("--- Verifying Automatic Timestamp Generation ---")
        
        # 1. Create a new User
        unique_email = f"test_user_{int(time.time())}@example.com"
        test_user = User(
            email=unique_email,
            full_name="Timestamp Test User",
            hashed_password="fakehash",
            is_active=True
        )
        db.add(test_user)
        db.commit()
        db.refresh(test_user)
        
        print(f"User created: {test_user.email}")
        print(f"  created_at: {test_user.created_at}")
        print(f"  updated_at: {test_user.updated_at}")
        
        assert test_user.created_at is not None, "created_at should not be None"
        assert test_user.updated_at is not None, "updated_at should not be None"
        
        # 2. Verify Update Logic
        print("\n--- Verifying Automatic Timestamp Update ---")
        original_updated_at = test_user.updated_at
        
        # Wait a moment to ensure timestamp difference
        print("Waiting 2 seconds...")
        time.sleep(2)
        
        test_user.full_name = "Updated Test User"
        db.add(test_user)
        db.commit()
        db.refresh(test_user)
        
        print(f"User updated: {test_user.full_name}")
        print(f"  created_at: {test_user.created_at} (should be same)")
        print(f"  updated_at: {test_user.updated_at} (should be newer)")
        
        assert test_user.updated_at > original_updated_at, "updated_at should be newer after update"
        assert test_user.created_at < test_user.updated_at, "created_at should be older than updated_at"
        
        # 3. Create a Product
        print("\n--- Verifying Product Timestamps ---")
        test_product = Product(
            name="Test Product",
            sku=f"TS-{int(time.time())}",
            price=10.0,
            is_active=True
        )
        db.add(test_product)
        db.commit()
        db.refresh(test_product)
        
        print(f"Product created: {test_product.name}")
        print(f"  created_at: {test_product.created_at}")
        print(f"  updated_at: {test_product.updated_at}")
        
        assert test_product.created_at is not None
        assert test_product.updated_at is not None
        
        print("\nVerification successful! Automatic timestamps are working correctly.")
        
    except AssertionError as e:
        print(f"\nVerification FAILED: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\nAn error occurred: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        db.close()

if __name__ == "__main__":
    verify_timestamps()
