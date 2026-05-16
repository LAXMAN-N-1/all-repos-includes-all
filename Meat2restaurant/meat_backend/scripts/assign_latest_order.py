import sys
import os
from dotenv import load_dotenv

# Add the backend directory to the Python path
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
sys.path.append(os.path.join(os.path.dirname(__file__), '../backend'))

# Load env execution BEFORE importing app modules
env_path = os.path.join(os.path.dirname(__file__), '../.env')
load_dotenv(env_path)

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.db.base import Base
from app.models.order import Order, OrderStatus
from app.models.user import User
from app.models.sales_extras import Shipment
from app.core.config import settings

# Database setup
# Re-import settings after loading env to ensure values are picked up if they were lazy loaded or if we need to reconstruct URI
# However, settings might have been instantiated already. 
# Let's manually construct the URL if needed or ensure settings re-reads env.
# Safest is to just override the URL if we can, or rely on load_dotenv being early enough if settings uses os.getenv at import time.
# But settings is already imported. Let's start by just loading dotenv.
# Actually, Pydantic settings usually read env on instantiation.
from app.core.config import settings
engine = create_engine(settings.SQLALCHEMY_DATABASE_URI)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
db = SessionLocal()

# Ensure tables exist
Base.metadata.create_all(bind=engine)

def assign_latest_order():
    # 1. Find a driver
    driver = db.query(User).filter(User.role == "driver").first()
    if not driver:
        print("Error: No user with role 'driver' found.")
        return

    print(f"Found Driver: {driver.full_name} (ID: {driver.id})")

    # 2. Find the latest order (Pending or Confirmed)
    order = db.query(Order).order_by(Order.id.desc()).first()
    
    if not order:
        print("Error: No orders found.")
        return

    print(f"Found Latest Order: #{order.id} | Status: {order.status}")

    # 3. Create or Update Shipment
    shipment = db.query(Shipment).filter(Shipment.order_id == order.id).first()
    if not shipment:
        print("Creating new shipment record...")
        shipment = Shipment(order_id=order.id, status="pending")
        db.add(shipment)
    
    # 4. Assign Driver
    shipment.driver_id = driver.id
    print(f"Assigning Order #{order.id} to Driver {driver.full_name}...")

    # 5. Update Order Status to CONFIRMED (if not already)
    # The app looks for 'confirmed' status
    if order.status == OrderStatus.PENDING:
        order.status = OrderStatus.CONFIRMED
        print(f"Updated Order Status to {OrderStatus.CONFIRMED}")
    elif order.status == OrderStatus.CONFIRMED:
        print("Order is already CONFIRMED.")
    else:
        print(f"Warning: Order status is {order.status}. Driver app looks for 'confirmed'. Updating to 'confirmed' for test.")
        order.status = OrderStatus.CONFIRMED

    db.commit()
    print("--------------------------------------------------")
    print(f"✅ Success! Order #{order.id} is now assigned to {driver.full_name}.")
    print("--------------------------------------------------")
    print("👉 Please ensure you are logged into the Driver App as:")
    print(f"   Email: {driver.email}")
    print("   (Or whatever credentials this user has)")

if __name__ == "__main__":
    assign_latest_order()
