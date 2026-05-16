import sys
from pathlib import Path
import random

# Add the parent directory to sys.path to allow importing from 'app'
# This assumes the script is in backend/scripts/ and needs to import from backend/
# backend/ is at parents[1] relative to backend/scripts/seed_us_data.py
# Check: backend/scripts -> backend is parent.
sys.path.append(str(Path(__file__).resolve().parents[1]))

from sqlalchemy.orm import Session
from sqlalchemy import text
from app.db.session import SessionLocal
from app.models import Category, Product, ProductVariant

def seed_us_data(db: Session):
    try:
        print("🇺🇸 STARTING US MARKET DATA SEED 🇺🇸")
        
        # 1. Wipe existing Catalog Data
        print("🔥 Wiping existing catalog data...")
        tables_to_wipe = ["product_variants", "products", "categories"]
        for table in tables_to_wipe:
            try:
                # Use cascade to handle foreign keys
                db.execute(text(f"TRUNCATE TABLE {table} RESTART IDENTITY CASCADE"))
                db.commit()
            except Exception as e:
                db.rollback()
                print(f"  ⚠️ Could not truncate {table}: {e}")

        # 2. Add US Categories
        print("🥩 Seeding US Categories...")
        categories_data = [
            {"name": "Beef", "desc": "Premium cuts, Steaks, Ground Beef"},
            {"name": "Pork", "desc": "Chops, Ribs, Bacon, Sausage"},
            {"name": "Poultry", "desc": "Chicken, Turkey, Duck"},
            {"name": "Lamb", "desc": "Chops, Leg, Rack of Lamb"},
            {"name": "Seafood", "desc": "Fish, Shrimp, Shellfish"},
            {"name": "Exotics", "desc": "Bison, Venison, Game Meats"},
            {"name": "Bundle Packs", "desc": "Bulk savings and sampler packs"},
        ]
        
        category_objs = {}
        for cat in categories_data:
            # Check if exists first to avoid duplicate key errors if truncate failed semi-silently
            existing = db.query(Category).filter(Category.name == cat["name"]).first()
            if not existing:
                c = Category(name=cat["name"], description=cat["desc"], is_active=True)
                db.add(c)
                db.flush() # get ID
                category_objs[cat["name"]] = c
            else:
                category_objs[cat["name"]] = existing
        
        db.commit()

        # 3. Add US Products
        print("🍔 Seeding US Products...")
        
        products_data = [
            # Beef
            {"cat": "Beef", "name": "Ribeye Steak", "price": 18.99, "wholesale": 14.50, "unit": "lbs"},
            {"cat": "Beef", "name": "Filet Mignon", "price": 24.99, "wholesale": 19.00, "unit": "lbs"},
            {"cat": "Beef", "name": "Ground Beef (80/20)", "price": 5.99, "wholesale": 3.50, "unit": "lbs"},
            {"cat": "Beef", "name": "NY Strip Steak", "price": 16.50, "wholesale": 12.00, "unit": "lbs"},
            {"cat": "Beef", "name": "Brisket", "price": 8.50, "wholesale": 5.50, "unit": "lbs"},
            
            # Pork
            {"cat": "Pork", "name": "Pork Chops (Bone-in)", "price": 6.99, "wholesale": 4.00, "unit": "lbs"},
            {"cat": "Pork", "name": "Bacon (Thick Cut)", "price": 7.50, "wholesale": 5.00, "unit": "lbs"},
            {"cat": "Pork", "name": "Pork Tenderloin", "price": 8.99, "wholesale": 6.00, "unit": "lbs"},
            
            # Poultry
            {"cat": "Poultry", "name": "Chicken Breast (Boneless)", "price": 5.99, "wholesale": 3.50, "unit": "lbs"},
            {"cat": "Poultry", "name": "Whole Chicken", "price": 3.99, "wholesale": 2.50, "unit": "lbs"},
            {"cat": "Poultry", "name": "Chicken Wings", "price": 4.50, "wholesale": 2.75, "unit": "lbs"},
            
            # Lamb
            {"cat": "Lamb", "name": "Lamb Chops", "price": 19.99, "wholesale": 15.00, "unit": "lbs"},
            {"cat": "Lamb", "name": "Leg of Lamb", "price": 12.50, "wholesale": 9.00, "unit": "lbs"},
            
            # Seafood
            {"cat": "Seafood", "name": "Atlantic Salmon Fillet", "price": 14.99, "wholesale": 11.00, "unit": "lbs"},
            {"cat": "Seafood", "name": "Jumbo Shrimp (16/20)", "price": 16.99, "wholesale": 13.00, "unit": "lbs"},
            
            # Exotics
            {"cat": "Exotics", "name": "Ground Bison", "price": 10.99, "wholesale": 8.00, "unit": "lbs"},
            {"cat": "Exotics", "name": "Venison Steaks", "price": 22.00, "wholesale": 17.50, "unit": "lbs"},
            
             # Bundles
            {"cat": "Bundle Packs", "name": "Family Grill Pack", "price": 85.00, "wholesale": 65.00, "unit": "box"},
            {"cat": "Bundle Packs", "name": "Breakfast Bundle", "price": 45.00, "wholesale": 32.00, "unit": "box"},
        ]

        sku_counter = 1000
        
        for p_data in products_data:
            sku_counter += 1
            main_sku = f"US-{p_data['cat'][:3].upper()}-{sku_counter}"
            
            # Get category ID
            cat_obj = category_objs.get(p_data["cat"])
            if not cat_obj:
                continue

            product = Product(
                name=p_data["name"],
                description=f"Fresh {p_data['name']} - Premium Quality from US Farms",
                price=p_data["price"],
                wholesale_price=p_data["wholesale"],
                sku=main_sku,
                unit=p_data["unit"],
                category_id=cat_obj.id,
                category=p_data["cat"],
                stock_quantity=random.randint(50, 500),
                is_active=True,
                min_order_quantity=5 if p_data["unit"] == "lbs" else 1
            )
            db.add(product)
            db.flush()
            
            # Add Variants logic: Steaks often have weights/thickness variances implies SKU variants
            # For simplicity, we add "Cut Sizes" for Steaks
            if "Steak" in p_data["name"] or "Chops" in p_data["name"]:
                variants_list = [
                    {"name": "Standard Cut (8oz)", "price_mod": -2.00},
                    {"name": "Thick Cut (12oz)", "price_mod": 2.50},
                    {"name": "Premium Cut (16oz)", "price_mod": 5.00}
                ]
                
                for idx, v in enumerate(variants_list):
                    mod_price = p_data["price"] + v["price_mod"]
                    mod_wholesale = p_data["wholesale"] + v["price_mod"]
                    v_sku = f"{main_sku}-V{idx+1}"
                    
                    variant = ProductVariant(
                        product_id=product.id,
                        sku=v_sku,
                        name=v["name"],
                        price=round(mod_price, 2) if mod_price > 0 else p_data["price"],
                        wholesale_price=round(mod_wholesale, 2) if mod_wholesale > 0 else p_data["wholesale"],
                        stock_quantity=random.randint(10, 50),
                        is_active=True
                    )
                    db.add(variant)

        db.commit()
        print("✅ US Data Seeding Complete!")

    except Exception as e:
        print(f"❌ Error during seeding: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
        raise

if __name__ == "__main__":
    db = SessionLocal()
    try:
        seed_us_data(db)
    except Exception as e:
        print("Failed to seed data.")
    finally:
        db.close()
