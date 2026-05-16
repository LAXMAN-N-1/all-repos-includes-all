import os
import sys
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Add parent directory to path to import app
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("DATABASE_URL not found in environment")
    sys.exit(1)

# Ensure it's a PostgreSQL URL for Neon
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

engine = create_engine(DATABASE_URL)

def clear_db():
    tables = [
        "order_status_updates",
        "order_items",
        "invoices",
        "shipments",
        "orders",
        "variant_attribute_values",
        "product_variants",
        "products",
        "attribute_values",
        "attributes",
        "categories",
        "memberships",
        "locations",
        "wallet_transactions",
        "gift_cards",
        "notifications",
        "customers",
        "users"
    ]
    
    with engine.connect() as conn:
        trans = conn.begin()
        try:
            print("Starting DB cleanup...")
            for table in tables:
                print(f"Clearing table: {table}")
                conn.execute(text(f"TRUNCATE TABLE {table} RESTART IDENTITY CASCADE;"))
            
            trans.commit()
            print("DB cleanup completed successfully!")
        except Exception as e:
            trans.rollback()
            print(f"Error during DB cleanup: {e}")
            sys.exit(1)

if __name__ == "__main__":
    # confirm = input("Are you sure you want to delete ALL products, categories, and orders? (y/N): ")
    # if confirm.lower() == 'y':
    clear_db()
    # else:
    #    print("Cleanup cancelled.")
