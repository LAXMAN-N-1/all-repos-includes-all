from sqlalchemy.orm import Session
from app.models.user import User
from app.models.role import Role
from app.models.organization import Organization
from app.core.security import get_password_hash
from app.database import SessionLocal
import sys

def seed_demo_users():
    db = SessionLocal()
    try:
        # 1. Ensure Default Organization exists
        org = db.query(Organization).filter(Organization.code == "DEMO_ORG").first()
        if not org:
            org = Organization(
                name="Demo Hospital Chain",
                code="DEMO_ORG",
                license_number="LIC-123456",
                email="admin@demohospital.com",
                phone="9876543210"
            )
            db.add(org)
            db.commit()
            db.refresh(org)
            print(f"  [OK] Created Demo Organization: {org.name}")
        else:
            print(f"  [SKIP] Demo Organization exists")

        # 2. Define Users
        # Format: (RoleCode, Email, Password, Name)
        # Note: Using 'laxman123' as password for all
        users_data = [
            ("ORG_ADMIN", "laxman@gmail.com", "laxman123", "Laxman OrgAdmin"),
            ("ORG_MANAGER", "mikeeyhen123@gmail.com", "laxman123", "Mike OrganizationMgr"),
            ("STORE_MANAGER", "fayaz@gmail.com", "laxman123", "Fayaz StoreMgr"),
            ("PHARMACIST", "sainanda@gmail.com", "laxman123", "Sainanda Pharmacist"),
            ("CASHIER", "siri@gmail.com", "laxman123", "Siri Cashier"),
            ("DOCTOR", "chandu@gmail.com", "laxman123", "Dr. Chandu"),
            ("NURSE", "koti@gmail.com", "laxman123", "Nurse Koti"),
            ("LAB_TECHNICIAN", "nithin@gmail.com", "laxman123", "Nithin LabTech"),
            ("PATIENT", "kiriti@gmail.com", "laxman123", "Kiriti Patient"),
            ("SAAS_SUPER_ADMIN", "laxmanlaxman1629@gmail.com", "laxman123", "Laxman SuperAdmin"),
        ]

        hashed_password = get_password_hash("laxman123") # Computed once since it's the same

        for role_code, email, raw_pass, name in users_data:
            # Check Role
            role = db.query(Role).filter(Role.code == role_code).first()
            if not role:
                print(f"  [ERR] Role {role_code} not found! Run seed_roles.py first.")
                continue

            # Check Existing User
            user = db.query(User).filter(User.email == email).first()
            if not user:
                user = User(
                    email=email,
                    full_name=name,
                    password_hash=hashed_password,
                    role_id=role.id,
                    organization_id=org.id,
                    is_active=True,
                    email_verified=True
                )
                db.add(user)
                print(f"  [ADD] Created user: {email} ({role_code})")
            else:
                # Update role if needed
                if user.role_id != role.id:
                    user.role_id = role.id
                    print(f"  [UPD] Updated role for: {email} -> {role_code}")
                else:
                    print(f"  [SKIP] User exists: {email}")

        db.commit()
        print("  [OK] User seeding completed.")

    except Exception as e:
        print(f"  [ERROR] Seeding failed: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    # Mock imports if needed or just run
    seed_demo_users()
