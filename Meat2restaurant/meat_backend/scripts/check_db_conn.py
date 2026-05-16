import sys
import os
sys.path.append(os.getcwd())

from app.db.session import SessionLocal
from sqlalchemy import text

def check_db():
    try:
        db = SessionLocal()
        result = db.execute(text("SELECT 1")).scalar()
        print(f"Database check result: {result}")
        db.close()
        return True
    except Exception as e:
        print(f"Database check failed: {e}")
        return False

if __name__ == "__main__":
    check_db()
