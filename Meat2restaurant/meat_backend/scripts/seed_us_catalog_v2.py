import os
import sys
import random
from datetime import datetime
from dotenv import load_dotenv

# Load env variables
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

# Add backend directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import text
from app.db.session import SessionLocal
from app.features.catalog.models.catalog import Category, Attribute, AttributeValue
from app.features.catalog.models.product import Product, ProductVariant

def seed_us_catalog():
    db = SessionLocal()
    print("🚀 Starting US Meat Catalog Seeding...")

    # Optional: Cleanup existing products to avoid conflicts
    print("🧹 Cleaning up old products and categories...")
    db.execute(text("DELETE FROM product_variants"))
    db.execute(text("DELETE FROM products"))
    db.execute(text("DELETE FROM categories"))
    db.commit()

    # 1. Define Categories with images (using poultry_organic_cat_v3_1772448062846.png for poultry)
    categories_data = [
        {"name": "USDA Prime Beef", "description": "Top 2% of US-graded beef, known for abundant marbling and superior flavor.", "image_url": "/static/beef_prime.png"},
        {"name": "Angus Ground Beef", "description": "High-quality Angus beef, freshly ground for the perfect burger or meatloaf.", "image_url": "/static/ground_beef.png"},
        {"name": "Heritage Breed Pork", "description": "Rare breed pork with exceptional fat quality and rich, deep flavor.", "image_url": "/static/heritage_pork.png"},
        {"name": "Organic Poultry", "description": "Free-range, organic certified poultry raised without antibiotics.", "image_url": "/poultry_organic_cat_v3_1772448062846.png"},
        {"name": "American Lamb", "description": "Tender, mild-flavored lamb raised on American pastures.", "image_url": "/static/american_lamb.png"},
        {"name": "Exotic Game Meats", "description": "Lean, nutrient-dense wild game including Bison, Elk, and Venison.", "image_url": "/static/game_meat.png"},
        {"name": "Artisan Deli Meats", "description": "Small-batch, hand-crafted deli meats and charcuterie.", "image_url": "/static/deli_meats.png"},
        {"name": "American Wagyu", "description": "The perfect cross of Japanese Wagyu rich marbling and American beef flavor.", "image_url": "/static/american_wagyu.png"},
        {"name": "Fresh Seafood", "description": "Sustainably sourced, fresh-caught seafood from US coastal waters.", "image_url": "/static/seafood.png"},
        {"name": "Plant-Based Alternatives", "description": "Next-generation meat alternatives that deliver the same great taste.", "image_url": "/static/plant_based.png"},
    ]

    # Create Categories
    category_map = {}
    for cat in categories_data:
        db_cat = db.query(Category).filter(Category.name == cat["name"]).first()
        if not db_cat:
            db_cat = Category(
                name=cat["name"],
                description=cat["description"],
                image_url=cat["image_url"],
                is_active=True
            )
            db.add(db_cat)
            db.flush()
        category_map[cat["name"]] = db_cat.id

    # 2. Define Attributes for Variants
    cut_attr = db.query(Attribute).filter(Attribute.name == "Cut Style").first()
    if not cut_attr:
        cut_attr = Attribute(name="Cut Style", is_active=True)
        db.add(cut_attr)
        db.flush()
    
    styles = ["Whole", "Diced", "Sliced", "Steak", "Ground", "Kabob"]
    style_values = {}
    for s in styles:
        val = db.query(AttributeValue).filter(AttributeValue.attribute_id == cut_attr.id, AttributeValue.value == s).first()
        if not val:
            val = AttributeValue(attribute_id=cut_attr.id, value=s)
            db.add(val)
            db.flush()
        style_values[s] = val

    # 3. Product Data (Simplified for brevity but representing the structure)
    products_by_category = {
        "USDA Prime Beef": [
            ("Prime Ribeye Steak", 34.99, "lb"), ("Prime Filet Mignon", 45.99, "lb"), ("Prime NY Strip Steak", 29.99, "lb"),
            ("Prime T-Bone Steak", 32.99, "lb"), ("Prime Porterhouse Steak", 36.99, "lb"), ("Prime Tomahawk Steak", 120.00, "unit"),
            ("Prime Picanha / Coulotte", 24.99, "lb"), ("Prime Flat Iron Steak", 19.99, "lb"), ("Prime Skirt Steak", 22.99, "lb"),
            ("Prime Flank Steak", 21.99, "lb"), ("Prime Hanger Steak", 25.99, "lb"), ("Prime Chuck Roast", 12.99, "lb"),
            ("Prime Brisket (Whole)", 110.00, "unit"), ("Prime Short Ribs", 18.99, "lb"), ("Prime Beef Shank", 9.99, "lb"),
            ("Prime Tri-Tip", 16.99, "lb"), ("Prime Eye of Round", 8.99, "lb"), ("Prime Top Sirloin", 15.99, "lb"),
            ("Prime Beef Tenderloin Whole", 250.00, "unit"), ("Prime Cowboy Ribeye", 49.99, "lb")
        ],
        "Angus Ground Beef": [
            ("Angus Ground Beef 80/20", 7.99, "lb"), ("Angus Ground Beef 90/10", 8.99, "lb"), ("Angus Ground Chuck", 8.49, "lb"),
            ("Angus Ground Round", 8.99, "lb"), ("Angus Ground Sirloin", 9.49, "lb"), ("Angus Burger Patties (4x1/4lb)", 9.99, "pack"),
            ("Angus Burger Patties (2x1/2lb)", 10.99, "pack"), ("Angus Sliders (6ct)", 12.99, "pack"), ("Angus Meatball Mix", 9.99, "lb"),
            ("Angus Ground Brisket", 10.99, "lb"), ("Angus Ground Short Rib", 11.99, "lb"), ("Angus Ground Beef 73/27", 6.99, "lb"),
            ("Angus Chili Meat", 8.99, "lb"), ("Angus Stew Meat", 9.99, "lb"), ("Angus Cubed Steak", 10.99, "lb"),
            ("Angus Taco Meat Blend", 9.49, "lb"), ("Angus Gourmet Burger Blend", 12.99, "lb"), ("Angus Grass-Fed Ground", 11.99, "lb"),
            ("Angus Dry-Aged Ground", 14.99, "lb"), ("Angus Bulk Ground (10lb)", 65.00, "unit")
        ],
        "Heritage Breed Pork": [
            ("Heritage Double-Cut Chops", 12.99, "lb"), ("Heritage Pork Loin Roast", 15.99, "lb"), ("Heritage Pork Tenderloin", 14.99, "lb"),
            ("Heritage Berkshire Belly", 11.99, "lb"), ("Heritage Boston Butt", 8.99, "lb"), ("Heritage Pork Shoulder Roast", 7.99, "lb"),
            ("Heritage Baby Back Ribs", 14.99, "lb"), ("Heritage St. Louis Ribs", 13.99, "lb"), ("Heritage Spare Ribs", 10.99, "lb"),
            ("Heritage Ground Pork", 7.49, "lb"), ("Heritage Pork Osso Buco", 10.99, "lb"), ("Heritage Pork Collar", 11.99, "lb"),
            ("Heritage Fresh Ham (Bone-In)", 45.00, "unit"), ("Heritage Smoked Ham", 55.00, "unit"), ("Heritage Pork Cheek", 9.99, "lb"),
            ("Heritage Pork Shank", 6.99, "lb"), ("Heritage Jowl Meat", 8.99, "lb"), ("Heritage Fatback", 4.99, "lb"),
            ("Heritage Leaf Lard", 12.99, "unit"), ("Heritage Pork Variety Pack", 150.00, "unit")
        ],
        "Organic Poultry": [
            ("Organic Whole Chicken", 18.00, "unit"), ("Organic Boneless Breast", 9.99, "lb"), ("Organic Chicken Thighs", 6.99, "lb"),
            ("Organic Chicken Wings", 7.99, "lb"), ("Organic Chicken Drumsticks", 4.99, "lb"), ("Organic Chicken Tenders", 10.99, "lb"),
            ("Organic Ground Chicken", 8.99, "lb"), ("Organic Chicken Quarters", 5.99, "lb"), ("Organic Whole Turkey", 45.00, "unit"),
            ("Organic Turkey Breast", 12.99, "lb"), ("Organic Ground Turkey", 9.99, "lb"), ("Organic Turkey Wings", 6.99, "lb"),
            ("Organic Cornish Hen", 12.00, "unit"), ("Organic Duck Breast", 19.99, "lb"), ("Organic Whole Duck", 35.00, "unit"),
            ("Organic Chicken Broth Bones", 3.99, "lb"), ("Organic Chicken Liver", 5.99, "lb"), ("Organic Chicken Heart/Gizzard", 4.99, "lb"),
            ("Organic Spatchcock Chicken", 22.00, "unit"), ("Organic Poultry Bundle", 85.00, "unit")
        ],
        "American Lamb": [
            ("Lamb Rack (Chop-Ready)", 24.99, "lb"), ("Lamb Loin Chops", 19.99, "lb"), ("Lamb Shoulder Chops", 14.99, "lb"),
            ("Lamb Leg Bone-In", 12.99, "lb"), ("Lamb Leg Boneless", 14.99, "lb"), ("Lamb Shank", 11.99, "lb"),
            ("Lamb Shoulder Roast", 13.99, "lb"), ("Lamb Ribs", 10.99, "lb"), ("Lamb Stew Meat", 12.99, "lb"),
            ("Ground Lamb", 11.49, "lb"), ("Lamb Kabob Meat", 13.99, "lb"), ("Lamb Neck (Braising)", 8.99, "lb"),
            ("Lamb Kidney", 6.99, "lb"), ("Lamb Liver", 7.99, "lb"), ("Lamb Sweetbreads", 15.99, "lb"),
            ("Lamb Fries", 12.99, "lb"), ("Lamb Tongue", 9.99, "lb"), ("Lamb Saddle", 18.99, "lb"),
            ("Butterflied Leg of Lamb", 16.99, "lb"), ("Lamb Sampler Box", 120.00, "unit")
        ],
        "Exotic Game Meats": [
            ("Bison Ribeye Steak", 28.99, "lb"), ("Bison Filet", 38.99, "lb"), ("Bison Ground", 12.99, "lb"),
            ("Bison Burger Patties", 14.99, "lb"), ("Bison Brisket", 15.99, "lb"), ("Bison Short Ribs", 16.99, "lb"),
            ("Elk Steak", 22.99, "lb"), ("Elk Medallions", 25.99, "lb"), ("Elk Ground", 13.99, "lb"),
            ("Venison Steak", 19.99, "lb"), ("Venison Roast", 17.99, "lb"), ("Venison Ground", 11.99, "lb"),
            ("Wild Boar Chops", 15.99, "lb"), ("Wild Boar Shoulder", 12.99, "lb"), ("Wild Boar Ground", 9.99, "lb"),
            ("Rabbit Whole", 18.00, "unit"), ("Alligator Tail Meat", 17.99, "lb"), ("Kangaroo Loin", 24.99, "lb"),
            ("Quail Whole (4ct)", 24.00, "unit"), ("Game Meat Sample Pack", 180.00, "unit")
        ],
        "Artisan Deli Meats": [
            ("Hand-Carved Roast Beef", 16.99, "lb"), ("Oven-Roasted Turkey", 14.99, "lb"), ("Black Forest Ham", 12.99, "lb"),
            ("Corned Beef (Deli)", 15.99, "lb"), ("Artisan Pastrami", 17.99, "lb"), ("Hard Salami", 11.99, "lb"),
            ("Genoa Salami", 10.99, "lb"), ("Mortadella w/ Pistachio", 13.99, "lb"), ("Prosciutto di Parma", 25.99, "lb"),
            ("Capicola (Hot)", 14.99, "lb"), ("Pancetta", 15.99, "lb"), ("Soppressata", 13.99, "lb"),
            ("Bologna (Gourmet)", 9.99, "lb"), ("Liverwurst", 8.99, "lb"), ("Pepperoni (Sliced)", 11.99, "lb"),
            ("Deli Chicken Breast", 13.99, "lb"), ("Honey Glazed Ham", 12.99, "lb"), ("Olive Loaf", 10.99, "lb"),
            ("Head Cheese", 11.99, "lb"), ("Deli Counter Party Tray", 65.00, "unit")
        ],
        "American Wagyu": [
            ("Wagyu Ribeye Steak (Marble 8+)", 85.00, "lb"), ("Wagyu Filet Mignon", 95.00, "lb"), ("Wagyu NY Strip", 75.00, "lb"),
            ("Wagyu Flat Iron", 35.00, "lb"), ("Wagyu Skirt Steak", 38.00, "lb"), ("Wagyu Denver Steak", 32.00, "lb"),
            ("Wagyu Zabuton Steak", 42.00, "lb"), ("Wagyu Ground (1lb)", 15.00, "unit"), ("Wagyu Burger Patties (2ct)", 18.00, "unit"),
            ("Wagyu Hot Dogs (8ct)", 12.00, "unit"), ("Wagyu Brisket (Whole)", 180.00, "unit"), ("Wagyu Short Ribs", 28.00, "lb"),
            ("Wagyu Tri-Tip", 25.00, "lb"), ("Wagyu Picanha", 32.00, "lb"), ("Wagyu Top Sirloin", 22.00, "lb"),
            ("Wagyu Roast", 18.00, "lb"), ("Wagyu Beef Tallow", 15.00, "unit"), ("Wagyu Sliders (12ct)", 35.00, "unit"),
            ("Wagyu Carne Asada", 28.00, "lb"), ("Ultimate Wagyu Box", 450.00, "unit")
        ],
        "Fresh Seafood": [
            ("Atlantic Salmon Fillet", 14.99, "lb"), ("Wild Alaskan Cod", 12.99, "lb"), ("American Red Snapper", 19.99, "lb"),
            ("Wild-Caught Shrimp (16/20)", 16.99, "lb"), ("Dungeness Crab Clusters", 24.99, "lb"), ("Maine Lobster Tail", 18.00, "unit"),
            ("Sea Scallops (U-10)", 29.99, "lb"), ("Yellowfin Tuna Steak", 18.99, "lb"), ("Halibut Fillet", 26.99, "lb"),
            ("Rainbow Trout", 11.99, "lb"), ("Mahi Mahi Fillet", 15.99, "lb"), ("Swordfish Steak", 17.99, "lb"),
            ("Chesapeake Bay Oysters (12ct)", 24.00, "unit"), ("PEI Mussels", 6.99, "lb"), ("Littleneck Clams", 7.99, "lb"),
            ("Fresh Striped Bass", 18.99, "lb"), ("Catfish Fillet", 9.99, "lb"), ("Maryland Blue Crab Cakes", 12.00, "unit"),
            ("Seafood Paella Mix", 22.99, "lb"), ("Clam Bake Bundle", 110.00, "unit")
        ],
        "Plant-Based Alternatives": [
            ("Ultimate Plant Burger Patties", 8.99, "pack"), ("Plant-Based Ground 'Beef'", 9.49, "lb"), ("Meatless Breakfast Sausage", 7.99, "pack"),
            ("Vegan Italian Sausage", 8.49, "pack"), ("Plant-Based Chicken Nuggets", 7.99, "pack"), ("Meatless Meatballs", 8.99, "lb"),
            ("Vegan Deli Turkey", 9.99, "lb"), ("Plant-Based Hot Dogs", 6.99, "pack"), ("Mushroom-Based Steak", 12.99, "lb"),
            ("Tofu Marinade Cubes", 5.99, "lb"), ("Tempeh Bacon Stripes", 6.49, "pack"), ("Seitan Slices", 7.99, "lb"),
            ("Jackfruit Pulled BBQ", 10.99, "lb"), ("Plant-Based Tuna", 8.99, "lb"), ("Vegan Crab Cakes", 10.99, "pack"),
            ("Plant-Based Chorizo", 8.49, "lb"), ("Vegan Pepperoni", 9.99, "lb"), ("Lentil-Based Ground", 7.49, "lb"),
            ("Plant-Based Whole Roast", 35.00, "unit"), ("Plant-Based Sample Box", 75.00, "unit")
        ]
    }

    print(f"Adding products to {len(products_by_category)} categories...")

    for cat_name, product_list in products_by_category.items():
        cat_id = category_map[cat_name]
        for name, price, unit in product_list:
            # More unique SKU generation
            safe_name = "".join(c for c in name if c.isalnum()).upper()
            sku = f"{cat_name[:3].upper()}-{safe_name[:10]}-{random.randint(1000, 9999)}"
            
            product = db.query(Product).filter(Product.sku == sku).first()
            if not product:
                product = Product(
                    name=name,
                    description=f"Premium grade {name} from our {cat_name} collection. Hand-selected for quality.",
                    price=price,
                    wholesale_price=round(price * 0.8, 2),
                    sku=sku,
                    unit=unit,
                    stock_quantity=random.randint(50, 200),
                    category_id=cat_id,
                    is_active=True,
                    # Fallback to category image if product image not specific
                    image_url=categories_data[next(i for i, v in enumerate(categories_data) if v["name"] == cat_name)]["image_url"]
                )
                db.add(product)
                db.flush()
                
                # Add variants to some products (approx 30% of them)
                if random.random() < 0.3:
                    # Choose 2 styles
                    styles_to_add = random.sample(styles, 2)
                    for style in styles_to_add:
                        v_sku = sku + "-" + style[:3].upper()
                        variant = ProductVariant(
                            product_id=product.id,
                            sku=v_sku,
                            name=f"{name} ({style})",
                            price=product.price if style != "Sliced" else product.price + 1.5,
                            wholesale_price=product.wholesale_price,
                            stock_quantity=random.randint(10, 50),
                            is_active=True
                        )
                        variant.attribute_values.append(style_values[style])
                        db.add(variant)

    db.commit()
    print("✅ Successfully seeded 200 products across 10 categories with variants!")

if __name__ == "__main__":
    seed_us_catalog()
