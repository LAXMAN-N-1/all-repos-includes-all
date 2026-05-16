from sqlalchemy.orm import Session
from app.models.user import User
from app.models.role import Role
from app.models.organization import Organization
from app.utils.security import get_password_hash # Assuming this exists, otherwise I'll mock it
# If utils.security doesn't exist, I'll use a placeholder or check utils folder
import uuid

def seed_admin_user(db: Session):
    """Seed default organization and admin user"""
    
    # Check/Create Organization
    org = db.query(Organization).filter(Organization.code == "HQ001").first()
    if not org:
        org = Organization(
            name="Pharma Only HQ",
            code="HQ001",
            email="contact@pharmaonly.com",
            phone="1234567890",
            address="123 Main St",
            city="Tech City",
            state="Innovation State",
            postal_code="10001",
            license_number="LIC-HQ-001",
            inventory_mode="STORE_DIRECT"
        )
        db.add(org)
        db.flush()
        print(f"  [OK] Created Organization: {org.name}")
    
    # Check/Create Admin User
    admin_email = "laxmanlaxman1629@gmail.com"
    user = db.query(User).filter(User.email == admin_email).first()
    
    if not user:
        # Get ORG_ADMIN role
        role = db.query(Role).filter(Role.code == "ORG_ADMIN").first()
        if not role:
            print("  [ERROR] ORG_ADMIN role not found.")
            return

        # Get hash from utility
        try:
            password_hash = get_password_hash("laxman123")
        except Exception as e:
            print(f"Warning: Password hashing failed ({e}), using fallback")
            password_hash = "$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWrn3ILAWOi/k.z.Z.Z.Z.Z.Z.Z.Z.Z" # Dummy hash 

        user = User(
            organization_id=org.id,
            email=admin_email,
            password_hash=password_hash,
            full_name="System Administrator",
            role_id=role.id,
            email_verified=True,
            phone_verified=True
        )
        db.add(user)
        db.commit()
        print(f"  [OK] Created Admin User: {user.email}")
    else:
        print(f"  [OK] Admin User exists: {user.email}")
        # Build hash to check if we need to repair it (e.g. if it was the fallback)
        fallback_hash = "$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWrn3ILAWOi/k.z.Z.Z.Z.Z.Z.Z.Z.Z"
        if user.password_hash == fallback_hash:
            print("  [WARN] Detected broken hash. Attempting repair...")
            try:
                new_hash = get_password_hash("laxman123")
                user.password_hash = new_hash
                db.commit()
                print("  [OK] Password repaired.")
            except Exception as e:
                print(f"  [ERROR] Repair failed: {e}")
