import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[0]))

from app.db.session import SessionLocal
from app import models
from app.api.endpoints.orders import create_order
from app.schemas.order import OrderCreate, OrderItemCreate
from fastapi import HTTPException
import unittest

class TestB2BFeatures(unittest.TestCase):
    def setUp(self):
        self.db = SessionLocal()
        # Find a B2B Partner
        self.partner = self.db.query(models.Customer).filter(models.Customer.customer_type == "b2b").first()
        # Find a Product
        self.product = self.db.query(models.Product).first()
        
        # Reset partner for clean test
        self.partner.current_balance = 0.0
        self.partner.credit_limit = 1000.0
        self.partner.is_verified = True
        self.partner.status = "verified"
        
        # Set product prices
        self.product.price = 100.0
        self.product.wholesale_price = 80.0
        self.product.volume_tiers = {"10": 70.0, "50": 60.0}
        self.product.stock_quantity = 1000
        self.product.min_order_quantity = 1
        
        self.db.commit()

    def tearDown(self):
        self.db.close()

    def test_credit_limit_enforcement(self):
        print("\n--- Testing Credit Limit Enforcement ---")
        # Try to order more than $1000
        # 15 * $80 = $1200 (Exceeds $1000 limit)
        order_in = OrderCreate(
            customer_id=self.partner.id,
            items=[OrderItemCreate(product_id=self.product.id, quantity=15)]
        )
        
        try:
            # We call the logic directly (mocking current_user)
            # In a real API call, deps.get_current_active_user would provide the partner
            from app.api.endpoints.orders import create_order
            # We need to bypass the FastAPI Depends for direct testing or mock the Request
            # Simpler: just call the function with the partner as current_user
            create_order(db=self.db, order_in=order_in, current_user=self.partner)
            self.fail("Order should have been rejected due to credit limit")
        except HTTPException as e:
            print(f"✅ Rejection Success: {e.detail}")
            self.assertEqual(e.status_code, 403)

    def test_volume_tier_pricing(self):
        print("\n--- Testing Volume Tier Pricing ---")
        
        # 1. Test Wholesale (Qty < 10)
        from app.api.endpoints.orders import create_order
        print(f"DEBUG: Partner Type: {self.partner.customer_type}")
        print(f"DEBUG: Product Wholesale Price: {self.product.wholesale_price}")
        
        order_1 = OrderCreate(
            customer_id=self.partner.id,
            items=[OrderItemCreate(product_id=self.product.id, quantity=5)]
        )
        # 5 * $80 = $400
        res_1 = create_order(db=self.db, order_in=order_1, current_user=self.partner)
        print(f"Qty 5 Price: ${res_1.total_amount} (Expected 400.0)")
        
        # Check an item's unit price
        item = res_1.items[0]
        print(f"DEBUG: Applied Unit Price: {item.unit_price}")
        
        self.assertEqual(res_1.total_amount, 400.0)
        
        # 2. Test Tier 1 (Qty 10)
        order_2 = OrderCreate(
            customer_id=self.partner.id,
            items=[OrderItemCreate(product_id=self.product.id, quantity=10)]
        )
        # 10 * $70 = $700
        res_2 = create_order(db=self.db, order_in=order_2, current_user=self.partner)
        print(f"Qty 10 Price: ${res_2.total_amount} (Expected 700.0)")
        self.assertEqual(res_2.total_amount, 700.0)

        # 3. Test Tier 2 (Qty 60)
        # Set limit higher for this test
        self.partner.credit_limit = 10000.0
        self.db.add(self.partner)
        self.db.flush()
        
        order_3 = OrderCreate(
            customer_id=self.partner.id,
            items=[OrderItemCreate(product_id=self.product.id, quantity=60)]
        )
        # 60 * $60 = $3600
        res_3 = create_order(db=self.db, order_in=order_3, current_user=self.partner)
        print(f"Qty 60 Price: ${res_3.total_amount} (Expected 3600.0)")
        self.assertEqual(res_3.total_amount, 3600.0)

if __name__ == "__main__":
    # Ensure models are loaded
    from app.db import base
    unittest.main()
