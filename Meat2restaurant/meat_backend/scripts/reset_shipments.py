from app.db.session import engine
from sqlalchemy import text

def reset_shipments():
    with engine.connect() as connection:
        # Drop shipments table to force recreation with new schema
        print("Dropping table 'shipments'...")
        try:
             connection.execute(text("DROP TABLE IF exists shipments CASCADE"))
             connection.commit()
             print("Table dropped.")
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    reset_shipments()
