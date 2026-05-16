import sys
import os

# Add the script's directory (backend) to sys.path to allow imports from app
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models import User, Role, Organization, Branch
# Import related models to clear them first to avoid foreign key constraints
from app.models.vendor_m import Vendor
from app.models.event_manager_profile_m import EventManagerProfile
from app.utils.password_utils import hash_password

def reset_and_seed_superadmin():
    db = SessionLocal()
    try:
        print("🗑️  Deleting existing Vendor Profiles...")
        db.query(Vendor).delete()
        
        print("🗑️  Deleting existing Event Manager Profiles...")
        db.query(EventManagerProfile).delete()
        
        print("🗑️  Deleting ALL Users...")
        db.query(User).delete()
        db.flush()

        print("🔍 Fetching Required Data (Organization, Branch, Role)...")
        # Assuming Organization and Branch exist from previous seeds
        org = db.query(Organization).first()
        branch = db.query(Branch).first()
        super_admin_role = db.query(Role).filter(Role.code == "SUPERADMIN").first()

        if not org or not branch or not super_admin_role:
            print("❌ Error: Missing base data (Organization, Branch, or SuperAdmin Role).")
            print("   Please run standard seed first if DB is empty.")
            return

        print("👤 Creating NEW Super Admin User...")
        new_super_admin = User(
            organization_id=org.id,
            branch_id=branch.id,
            role_id=super_admin_role.id,
            username="laxman", # Using first name or distinct username
            email="laxmanlaxman1629@gmail.com",
            password_hash=hash_password("laxman123"),
            first_name="Laxman",
            last_name="Admin",
            created_by="system_reset_script",
            phone="9999999999", # Dummy phone
            is_verified=True
        )
        db.add(new_super_admin)
        db.commit()

        print("\n" + "="*60)
        print("✅ SUCCESS! Users reset and Super Admin seeded.")
        print(f"📧 Email:    laxmanlaxman1629@gmail.com")
        print(f"🔑 Password: laxman123")
        print("="*60)

    except Exception as e:
        print(f"❌ Error during reset: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    reset_and_seed_superadmin()
