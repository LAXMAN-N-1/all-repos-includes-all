from app.database import engine, SessionLocal, Base
from app.config import settings
from sqlalchemy import text
from sqlalchemy.orm import Session
from app.models.organization import Organization

print(f"Configured DATABASE_URL: {settings.DATABASE_URL}")

with engine.connect() as conn:
    print("Testing RAW SQL query...")
    try:
        result = conn.execute(text("SELECT count(*) FROM organizations;"))
        print(f"Raw SQL count: {result.scalar()}")
    except Exception as e:
        print(f"Raw SQL failed: {e}")

    print("\nTesting ORM query...")
    print(f"Organization Table Name: {Organization.__table__.name}")
    print(f"Organization Schema: {Organization.__table__.schema}")
    print(f"\nMetadata tables: {Base.metadata.tables.keys()}")
    print(f"Organization table object: {Organization.__table__}")
    
    try:
        with Session(engine) as session:
            orgs = session.query(Organization).all()
            print(f"ORM Organization found: {len(orgs)}")
    except Exception as e:
        print(f"ORM Organization failed: {e}")

    print("\nTesting ORM Role query...")
    from app.models.role import Role
    try:
        with Session(engine) as session:
            roles = session.query(Role).all()
            print(f"ORM Role found: {len(roles)}")
    except Exception as e:
        print(f"ORM Role failed: {e}")
