import sys
import os

# Add the script's directory (backend) to sys.path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models import User, Role, Organization, Branch, Vendor
from app.utils.password_utils import hash_password

def seed_real_users():
    db = SessionLocal()
    try:
        print("🔍 Fetching Roles...")
        vendor_role = db.query(Role).filter(Role.code == "VENDOR").first()
        customer_role = db.query(Role).filter(Role.code == "CUSTOMER").first()
        
        if not vendor_role or not customer_role:
            print("❌ Error: Vendor or Customer roles not found.")
            return

        print("🗑️  Cleaning up existing Vendor and Customer users...")
        # Get users to delete to handle relationships if needed
        users_to_delete = db.query(User).filter(User.role_id.in_([vendor_role.id, customer_role.id])).all()
        for user in users_to_delete:
            if user.role_id == vendor_role.id:
                 db.query(Vendor).filter(Vendor.user_id == user.id).delete()
            db.delete(user)
        
        db.flush()
        
        # Base Org/Branch
        org = db.query(Organization).first()
        branch = db.query(Branch).first()

        # --- Create REAL VENDOR ---
        print("👤 Creating Real Vendor: Mohith...")
        mohith_vendor = User(
            organization_id=org.id,
            branch_id=branch.id,
            role_id=vendor_role.id,
            username="mohith",
            email="mohith@gmail.com",
            password_hash=hash_password("laxman123"),
            first_name="Mohith",
            last_name="Vendor",
            created_by="system", # Marked as system/real user
            phone="9888888888",
            is_verified=True
        )
        db.add(mohith_vendor)
        db.flush() 

        # Create Vendor Profile
        mohith_profile = Vendor(
            user_id=mohith_vendor.id,
            company_name="Mohith Events",
            company_type="Individual",
            city="Hyderabad",
            status="approved",
            is_verified=True,
            phone="9888888888",
            created_by="system"
        )
        db.add(mohith_profile)

        # --- Create REAL CUSTOMER ---
        print("👤 Creating Real Customer: Mike...")
        mike_customer = User(
            organization_id=org.id,
            branch_id=branch.id,
            role_id=customer_role.id,
            username="mikeeyhen",
            email="mikeeyhen123@gmail.com",
            password_hash=hash_password("laxman123"),
            first_name="Mikeey",
            last_name="Hen",
            created_by="system", # Marked as system/real user
            phone="9777777777",
            is_verified=True
        )
        db.add(mike_customer)

        db.commit()

        print("\n" + "="*60)
        print("✅ SUCCESS! Real Production Users Seeded.")
        print(f"1. Vendor:   mohith@gmail.com")
        print(f"2. Customer: mikeeyhen123@gmail.com")
        print("="*60)

    except Exception as e:
        print(f"❌ Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_real_users()
