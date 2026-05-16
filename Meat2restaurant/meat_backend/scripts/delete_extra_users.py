import os
import sys
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("DATABASE_URL not found in environment")
    sys.exit(1)

if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

engine = create_engine(DATABASE_URL)

def delete_target_users():
    with engine.connect() as conn:
        trans = conn.begin()
        try:
            print("Deleting non-Laxman users...")
            # Strictly keep ONLY the two requested Laxman emails
            result = conn.execute(text("""
                DELETE FROM users 
                WHERE email NOT IN ('laxmanlaxman1629@gmail.com', '9154345918')
            """))
            trans.commit()
            print(f"Cleanup completed. Deleted {result.rowcount} users.")
            
            # Verify remaining
            res = conn.execute(text("SELECT email, full_name, role FROM users"))
            print("\nRemaining Users:")
            for r in res:
                print(f"- {r.full_name} ({r.email}) [{r.role}]")
                
        except Exception as e:
            trans.rollback()
            print(f"Error: {e}")
            sys.exit(1)

if __name__ == "__main__":
    delete_target_users()
