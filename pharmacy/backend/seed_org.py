import os
import sys
from dotenv import load_dotenv
load_dotenv("backend/.env")

sys.path.append(os.getcwd())
# Also append backend dir
sys.path.append(os.path.join(os.getcwd(), 'backend'))


from app.database import SessionLocal, engine
from app.models.organization import Organization

def seed_org():
    db = SessionLocal()
    try:
        org = db.query(Organization).filter_by(id=1).first()
        if not org:
            print("Creating Default Organization...")
            org = Organization(
                id=1,
                name="AuraMed Platform",
                code="AURAMED_PLATFORM",
                inactive=False
            )
            db.add(org)
            db.commit()
            print("Default Organization Created.")
        else:
            print("Org 1 exists.")

        # Seed Roles
        from app.models.role import Role
        roles_data = [
            {"name": "HQ Admin", "code": "HQ_ADMIN", "is_system_role": True},
            {"name": "Store Admin", "code": "STORE_ADMIN", "is_system_role": True},
            {"name": "Pharmacist", "code": "PHARMACIST", "is_system_role": True},
            {"name": "Customer", "code": "CUSTOMER", "is_system_role": True},
        ]
        
        for r in roles_data:
            existing = db.query(Role).filter_by(code=r["code"]).first()
            if not existing:
                print(f"Creating Role: {r['name']}")
                new_role = Role(name=r["name"], code=r["code"], is_system_role=r["is_system_role"], inactive=False)
                db.add(new_role)
        db.commit()
        print("Roles Seeded.")
            
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_org()
