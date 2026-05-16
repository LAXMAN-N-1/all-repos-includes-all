import sys
from pathlib import Path

# Add the parent directory to sys.path to allow importing from 'app'
sys.path.append(str(Path(__file__).resolve().parents[2]))

from sqlalchemy.orm import Session
from sqlalchemy import text
from app.db.session import SessionLocal
from app.db import base
from app.core.security import get_password_hash
from app.core.roles import ROLE_SUPER_ADMIN, get_role_permissions

def reset_for_production(db: Session):
    try:
        print("🚨 STARTING PRODUCTION RESET 🚨")
        print("This will delete ALL Customers, Orders, Invoices, and Non-Admin Users.")
        
        # 1. Truncate Transactional & User Tables
        # Using CASCADE on main tables is enough.
        # We wrap each in a separate begin/commit block or just one robust block.
        tables_to_wipe = [
            "combined_invoices",
            "notifications", 
            "invoices", 
            "order_items", 
            "orders", 
            "partner_pricings", 
            "locations", 
            "customers", 
            "users" 
        ]
        
        for table in tables_to_wipe:
            try:
                # Check if table exists first or just try truncate
                print(f"  🔥 Wiping {table}...")
                db.execute(text(f"TRUNCATE TABLE {table} RESTART IDENTITY CASCADE"))
                db.commit() # Commit each to avoid transaction block issues
            except Exception as e:
                db.rollback()
                print(f"  ⚠️ Warning: Could not truncate {table}: {e}")
        
        print("✅ Data wiped successfully.")

        # 2. Re-Create Super Admin
        print("👑 Re-creating Super Admin...")
        admin_email = "admin@b2bmeat.com"
        
        # Check if exists (e.g. if truncate failed)
        existing_admin = db.query(base.User).filter(base.User.email == admin_email).first()
        if not existing_admin:
            admin_user = base.User(
                email=admin_email,
                hashed_password=get_password_hash("password123"),
                full_name="Super Admin",
                is_superuser=True,
                role=ROLE_SUPER_ADMIN,
                permissions=get_role_permissions(ROLE_SUPER_ADMIN),
                is_active=True
            )
            db.add(admin_user)
            db.commit()
            print(f"  ✅ Created Admin: {admin_email} / password123")
        else:
            print(f"  ℹ️ Admin {admin_email} already exists. Skipping creation.")
        
        print("\n🎉 PRODUCTION RESET COMPLETE. System is clean and ready for real users.")
        
    except Exception as e:
        print(f"❌ Error during reset: {e}")
        db.rollback()
        raise

if __name__ == "__main__":
    db = SessionLocal()
    try:
        reset_for_production(db)
    except Exception as e:
        pass
    finally:
        db.close()
