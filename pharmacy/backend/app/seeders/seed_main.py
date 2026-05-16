from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.seeders.seed_roles import seed_roles
from app.seeders.seed_permissions import seed_permissions
from app.seeders.seed_menus import seed_menus
from app.seeders.seed_admin import seed_admin_user

def run_seeders():
    """Run all database seeders"""
    db = SessionLocal()
    
    try:
        print("Starting database seeding...")
        
        print("Seeding roles...")
        seed_roles(db)
        
        print("Seeding permissions...")
        seed_permissions(db)
        
        print("Seeding menus...")
        seed_menus(db)
        
        print("Seeding admin user...")
        seed_admin_user(db)
        
        print("Database seeding completed!")
        
    except Exception as e:
        print(f"Error during seeding: {str(e)}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    run_seeders()