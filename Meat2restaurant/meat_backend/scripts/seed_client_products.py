"""
Seed script: Replace ALL products/categories with the client's exact product list.
Categories: Chicken (with sub-categories), Mutton, Seafood, Whole Boxes
Prices: $10–$20/lb range based on product type
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

engine = create_engine(settings.SQLALCHEMY_DATABASE_URI)
Session = sessionmaker(bind=engine)
db = Session()

# ═══════════════ STEP 1: CLEAR ALL EXISTING PRODUCTS & CATEGORIES ═══════════════
print("🗑️  Clearing existing data...")
for tbl in ["order_items", "product_reviews", "variant_attribute_values", "product_variants", "products", "categories"]:
    try:
        db.execute(text(f"DELETE FROM {tbl}"))
        db.commit()
        print(f"   Cleared {tbl}")
    except Exception as e:
        db.rollback()
        print(f"   Skipped {tbl}: {e}")
print("✅ Cleared old data")

# ═══════════════ STEP 2: CREATE CATEGORIES ═══════════════
def make_cat(name, desc, parent_id=None):
    db.execute(text(
        "INSERT INTO categories (name, description, parent_id, is_active, image_url, icon_url) "
        "VALUES (:n, :d, :p, true, NULL, NULL)"
    ), {"n": name, "d": desc, "p": parent_id})
    db.commit()
    row = db.execute(text("SELECT id FROM categories WHERE name = :n ORDER BY id DESC LIMIT 1"), {"n": name}).fetchone()
    return row[0]

print("\n📂 Creating categories...")

# Top-level categories
chicken_id = make_cat("Chicken", "Fresh chicken cuts and whole chicken")
mutton_id  = make_cat("Mutton", "Fresh goat, lamb & frozen mutton products")
seafood_id = make_cat("Seafood", "Fresh fish, shrimp, and seafood")
boxes_id   = make_cat("Whole Boxes", "Whole unopened boxes — bulk wholesale")

# Chicken sub-categories
leg_q_id  = make_cat("Leg Quarters", "Chicken leg quarter cuts", chicken_id)
thigh_id  = make_cat("Thigh", "Chicken thigh cuts", chicken_id)
breast_id = make_cat("Breast", "Chicken breast cuts", chicken_id)
whole_id  = make_cat("Whole Chicken", "Whole chicken cuts", chicken_id)
parts_id  = make_cat("Parts & Pieces", "Lollipops, wings, drumsticks", chicken_id)

print("✅ Categories created")

# ═══════════════ STEP 3: CREATE PRODUCTS ═══════════════
SKU_COUNTER = [1000]

def add(name, cat_id, price, wholesale, category_str, desc=None):
    SKU_COUNTER[0] += 1
    sku = f"MP-{SKU_COUNTER[0]}"
    db.execute(text(
        "INSERT INTO products (name, description, price, wholesale_price, sku, stock_quantity, "
        "unit, min_order_quantity, category_id, is_active, is_popular, is_bestseller, is_special, category) "
        "VALUES (:name, :desc, :price, :wp, :sku, 500, 'lbs', 1, :cid, true, false, false, false, :cat)"
    ), {"name": name, "desc": desc or name, "price": price, "wp": wholesale, "sku": sku, "cid": cat_id, "cat": category_str})

print("\n🥩 Seeding products...")

# ─── CHICKEN — Leg Quarters ───
add("Chicken Leg Quarters - 2 Piece Cut",  leg_q_id, 12.99, 10.50, "Chicken")
add("Chicken Leg Quarters - 3 Piece Cut",  leg_q_id, 12.99, 10.50, "Chicken")
add("Chicken Leg Quarters - 4 Piece Cut",  leg_q_id, 12.99, 10.50, "Chicken")
add("Chicken Leg Quarters - 5 Piece Cut",  leg_q_id, 12.99, 10.50, "Chicken")
add("Chicken Leg Quarters - 6 Piece Cut",  leg_q_id, 12.99, 10.50, "Chicken")

# ─── CHICKEN — Thigh ───
add("Thigh Only Clean",                    thigh_id, 14.99, 12.00, "Chicken")
add("Thigh Cubes for 65",                  thigh_id, 15.99, 13.00, "Chicken")
add("Thigh Cubes for Curry - Medium",      thigh_id, 15.99, 13.00, "Chicken")
add("Thigh for Kabab - 2 Piece Cut",       thigh_id, 15.99, 13.00, "Chicken")

# ─── CHICKEN — Breast ───
add("Chicken Breast Only Clean",           breast_id, 15.99, 13.00, "Chicken")
add("Chicken Breast Cubes",               breast_id, 16.99, 14.00, "Chicken")
add("Chicken Breast Fajitas",             breast_id, 16.99, 14.00, "Chicken")

# ─── CHICKEN — Whole Chicken ───
add("Whole Chicken - Medium Cut",          whole_id, 11.99, 10.00, "Chicken")
add("Whole Chicken - Small Cut",           whole_id, 11.99, 10.00, "Chicken")

# ─── CHICKEN — Parts & Pieces ───
add("Chicken Lollipop",                    parts_id, 14.99, 12.50, "Chicken")
add("Chicken Jumbo Wings",                 parts_id, 13.99, 11.50, "Chicken")
add("Chicken Split Wings",                 parts_id, 13.99, 11.50, "Chicken")
add("Chicken Jumbo Drumsticks",            parts_id, 13.99, 11.50, "Chicken")
add("Chicken Medium Drumsticks",           parts_id, 12.99, 10.50, "Chicken")

# ─── WHOLE BOXES (Bulk) ───
add("Leg Quarters - Whole Box",            boxes_id, 10.99, 9.00,  "Whole Boxes", "New unopened box — Leg Quarters")
add("Thigh - Whole Box",                   boxes_id, 12.99, 10.50, "Whole Boxes", "New unopened box — Thigh")
add("Leg Meat - Whole Box",                boxes_id, 11.99, 10.00, "Whole Boxes", "New unopened box — Leg Meat")
add("Breast - Whole Box",                  boxes_id, 13.99, 11.50, "Whole Boxes", "New unopened box — Breast")
add("Whole Chicken - Whole Box",           boxes_id, 10.99, 9.00,  "Whole Boxes", "New unopened box — Whole Chicken")
add("Wings - Whole Box",                   boxes_id, 12.99, 10.50, "Whole Boxes", "New unopened box — Wings")

# ─── MUTTON ───
add("Fresh Baby Goat - Curry Cut",         mutton_id, 18.99, 16.00, "Mutton")
add("Fresh Baby Goat - Biryani Cut",       mutton_id, 18.99, 16.00, "Mutton")
add("Goat Keema",                          mutton_id, 17.99, 15.00, "Mutton")
add("Goat Boneless",                       mutton_id, 19.99, 17.00, "Mutton")
add("Lamb Boneless",                       mutton_id, 19.99, 17.00, "Mutton")
add("Goat Shanks",                         mutton_id, 17.99, 15.50, "Mutton")
add("Frozen Goat Curry Cut",               mutton_id, 15.99, 13.00, "Mutton")
add("Frozen Goat Biryani Cut",             mutton_id, 15.99, 13.00, "Mutton")
add("Goat Liver",                          mutton_id, 12.99, 10.50, "Mutton")
add("Burnt Paya",                          mutton_id, 11.99, 10.00, "Mutton")
add("Goat Spleen",                         mutton_id, 12.99, 10.50, "Mutton")
add("Goat Boti",                           mutton_id, 14.99, 12.50, "Mutton")
add("Goat Testicles",                      mutton_id, 14.99, 12.50, "Mutton")
add("Goat Brain",                          mutton_id, 16.99, 14.00, "Mutton")
add("Goat Head",                           mutton_id, 13.99, 11.50, "Mutton")

# ─── SEAFOOD ───
add("Tilapia",                             seafood_id, 12.99, 10.50, "Seafood")
add("Golden Pompret Small",               seafood_id, 14.99, 12.50, "Seafood")
add("Golden Pompret Big",                 seafood_id, 17.99, 15.00, "Seafood")
add("Kingfish",                            seafood_id, 18.99, 16.00, "Seafood")
add("Shrimp 31/40 Tail Off",              seafood_id, 13.99, 11.50, "Seafood")
add("Shrimp 16/20 Tail Off",              seafood_id, 16.99, 14.00, "Seafood")

db.commit()

total = db.execute(text("SELECT COUNT(*) FROM products")).scalar()
cats = db.execute(text("SELECT COUNT(*) FROM categories")).scalar()
print(f"\n✅ Done! Seeded {total} products across {cats} categories.")
print("\n📋 Product summary:")
rows = db.execute(text(
    "SELECT c.name, COUNT(p.id) FROM categories c "
    "LEFT JOIN products p ON p.category_id = c.id "
    "GROUP BY c.name ORDER BY c.name"
)).fetchall()
for name, count in rows:
    print(f"   {name}: {count} products")

db.close()
