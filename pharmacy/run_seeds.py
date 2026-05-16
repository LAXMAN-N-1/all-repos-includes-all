import sys
import os

# Add backend to path
sys.path.append(os.path.join(os.getcwd(), "backend"))

from app.database import SessionLocal
from app.seeders.seed_roles import seed_roles
from app.seeders.seed_demo_users import seed_demo_users

def main():
    print("🚀 Starting Database Seeding...")
    
    db = SessionLocal()
    try:
        # 1. Seed Roles
        print("🌱 Seeding Roles...")
        seed_roles(db)
        
        # 2. Seed Users
        print("🌱 Seeding Users...")
        seed_demo_users() # Has its own session management
        
        print("✅ Seeding Complete!")
    except Exception as e:
        print(f"❌ Seeding Failed: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    main()
