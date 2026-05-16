import os
import sys
from dotenv import load_dotenv

# Load env variables before importing anything from app
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

# Add backend directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.db.session import SessionLocal
from app.models.catalog import Category
from app.models.product import Product

def create_catalog():
    db = SessionLocal()
    
    catalog_data = {
        "🥩 BEEF": [
            "Ground Beef (70/30, 80/20, 85/15, 90/10, 93/7, 96/4)",
            "Ground Chuck", "Ground Round", "Ground Sirloin", "Ground Brisket",
            "Ribeye Steak", "New York Strip Steak", "T-Bone Steak", "Porterhouse Steak",
            "Filet Mignon / Tenderloin Steak", "Sirloin Steak", "Flank Steak",
            "Skirt Steak (Inside & Outside)", "Hanger Steak", "Flat Iron Steak",
            "Chuck Eye Steak", "Denver Steak", "Tri-Tip Steak", "London Broil",
            "Coulotte / Top Sirloin Cap Steak", "Chuck Roast", "Brisket (Flat & Point)",
            "Ribeye Roast / Prime Rib", "Eye of Round Roast", "Bottom Round Roast",
            "Top Round Roast", "Sirloin Tip Roast", "Rump Roast", "Tri-Tip Roast",
            "Tenderloin Roast", "Beef Short Ribs (Bone-In)", "Flanken-Style Short Ribs",
            "Back Ribs", "Beef Plate Ribs", "Beef Stew Meat", "Beef Kabob / Cubed Steak",
            "Beef Oxtail", "Beef Shank (Cross-Cut)", "Beef Cheeks", "Beef Tongue",
            "Beef Liver", "Beef Heart", "Beef Kidney", "Beef Tripe", "Beef Marrow Bones",
            "Beef Soup Bones", "Corned Beef", "Beef Jerky", "Beef Hot Dogs", "Beef Sausages",
            "Beef Bologna", "Beef Salami", "Pastrami", "Beef Burger Patties (Fresh & Frozen)"
        ],
        "🐷 PORK": [
            "Bone-In Pork Chops", "Boneless Pork Chops", "Ribeye Pork Chops", 
            "Sirloin Pork Chops", "Thin-Cut Pork Chops", "Center-Cut Pork Chops",
            "Pork Shoulder / Boston Butt", "Pork Loin Roast", "Pork Tenderloin",
            "Pork Sirloin Roast", "Pork Leg / Fresh Ham", "Baby Back Ribs", "Spare Ribs",
            "St. Louis Style Ribs", "Country-Style Ribs", "Ground Pork (Regular & Lean)",
            "Ground Pork Sausage", "Pork Belly (Skin-On / Skinless)", "Pork Hocks",
            "Pork Knuckle", "Pork Feet / Trotters", "Pork Ears", "Pork Tail", "Pork Liver",
            "Pork Heart", "Pork Tongue", "Pork Fatback", "Pork Skin / Crackling", 
            "Regular Sliced Bacon", "Thick-Cut Bacon", "Center-Cut Bacon", 
            "Canadian Bacon / Back Bacon", "Pancetta", "Uncured Bacon", "Bone-In Ham",
            "Boneless Ham", "Spiral-Cut Ham", "Ham Steak", "Deli Ham (Sliced)",
            "Prosciutto", "Serrano Ham", "Pork Sausage Links (Breakfast)",
            "Pork Sausage Patties", "Italian Sausage (Sweet, Mild, Hot)", "Bratwurst",
            "Kielbasa / Polish Sausage", "Chorizo", "Andouille Sausage", "Pepperoni",
            "Salami", "Mortadella", "Pork Hot Dogs", "Pulled Pork (Pre-cooked)", "Pork Rinds"
        ],
        "🐔 POULTRY": [
            "Whole Chicken", "Rotisserie Chicken (Pre-cooked)", "Cornish Game Hen",
            "Chicken Breast (Bone-In / Boneless, Skin-On / Skinless)", 
            "Chicken Thighs (Bone-In / Boneless, Skin-On / Skinless)", "Chicken Drumsticks",
            "Chicken Wings (Whole, Flats, Drums)", "Chicken Leg Quarters",
            "Chicken Tenders / Strips", "Chicken Backs", "Chicken Necks",
            "Chicken Giblets (Heart, Liver, Gizzard)", "Chicken Feet", 
            "Ground Chicken (Regular & Lean)", "Whole Turkey", "Whole Turkey Breast",
            "Turkey Breast (Bone-In / Boneless)", "Turkey Thighs", "Turkey Drumsticks",
            "Turkey Wings", "Turkey Legs", "Ground Turkey (Regular, Lean, Extra Lean)",
            "Turkey Sausage", "Turkey Bacon", "Turkey Burger Patties", "Turkey Cutlets",
            "Whole Duck", "Duck Breast", "Duck Legs / Confit", "Duck Wings", "Ground Duck",
            "Whole Goose", "Goose Breast", "Quail (Whole)", "Pheasant",
            "Ostrich (Steak, Ground)", "Emu"
        ],
        "🐑 LAMB & MUTTON": [
            "Lamb Chops (Rib, Loin, Shoulder)", "Rack of Lamb", "Leg of Lamb (Bone-In / Boneless)",
            "Lamb Shoulder Roast", "Lamb Shank", "Lamb Ribs", "Ground Lamb", "Lamb Stew Meat",
            "Lamb Liver", "Lamb Kidney", "Mutton Chops", "Mutton Leg", "Ground Mutton"
        ],
        "🐐 GOAT": [
            "Goat Chops", "Goat Leg", "Goat Shoulder", "Goat Ribs", "Ground Goat",
            "Goat Stew Meat", "Goat Liver", "Goat Kidney", "Baby Goat (Cabrito) — Whole"
        ],
        "🦌 GAME MEAT": [
            "Venison Steak", "Venison Roast", "Venison Ribs", "Ground Venison",
            "Venison Sausage", "Venison Jerky", "Bison Ribeye Steak", "Bison Sirloin Steak",
            "Bison Tenderloin", "Bison Roast", "Ground Bison", "Bison Burger Patties",
            "Bison Short Ribs", "Bison Sausage", "Bison Jerky", "Elk Steak", "Elk Roast",
            "Ground Elk", "Elk Sausage", "Wild Boar Chops", "Wild Boar Ribs",
            "Ground Wild Boar", "Wild Boar Sausage", "Rabbit (Whole, Parts)",
            "Alligator (Tail Meat, Ground)", "Kangaroo (Steak, Ground)", "Exotic Game Sampler Packs"
        ],
        "🐟 SEAFOOD": [
            "Salmon (Fillet, Steak, Whole)", "Tilapia", "Cod", "Halibut",
            "Tuna (Steak, Canned)", "Mahi-Mahi", "Catfish", "Trout", "Swordfish",
            "Snapper", "Flounder", "Bass", "Grouper", 
            "Shrimp (Various sizes, Raw/Cooked, Peeled/Shell-On)",
            "Lobster (Whole, Tails, Claws)", "Crab (King, Snow, Dungeness, Blue)",
            "Scallops", "Clams", "Mussels", "Oysters", "Squid / Calamari", "Octopus"
        ],
        "🌿 PLANT-BASED": [
            "Beyond Meat Burger Patties", "Beyond Meat Sausage", "Impossible Burger Patties",
            "Impossible Sausage", "Plant-Based Ground \"Beef\"", 
            "Plant-Based Chicken (Nuggets, Strips, Patties)", "Meatless Meatballs",
            "Plant-Based Hot Dogs", "Tofu-Based Deli Slices", "Seitan / Wheat Meat Products",
            "Jackfruit (Pulled \"Pork\" Style)"
        ],
        "🥪 DELI MEAT / CHARCUTERIE": [
            "Roast Beef (Deli-Sliced)", "Turkey Breast (Deli-Sliced)", "Ham (Deli-Sliced)",
            "Chicken Breast (Deli-Sliced)", "Salami (Various)", "Bologna", "Pastrami",
            "Corned Beef", "Mortadella", "Head Cheese", "Liverwurst / Braunschweiger",
            "Summer Sausage", "Pepperoni (Sliced)", "Prosciutto", "Capicola / Coppa",
            "Sopressata"
        ]
    }

    print("Starting database seeding...")

    for cat_name, products in catalog_data.items():
        # Check if category exists
        category = db.query(Category).filter(Category.name == cat_name).first()
        if not category:
            category = Category(name=cat_name, is_active=True)
            db.add(category)
            db.flush()
            print(f"Created Category: {cat_name}")
        else:
            print(f"Category already exists: {cat_name}")

        for prod_name in products:
            # Check if product exists
            product = db.query(Product).filter(Product.name == prod_name).first()
            if not product:
                base_price = 10.0 # Default fallback price
                # Add default product configuration
                product = Product(
                    name=prod_name,
                    description=f"Premium quality {prod_name}",
                    price=base_price,
                    wholesale_price=base_price * 0.8,
                    sku=prod_name.replace(" ", "-").replace("(", "").replace(")", "").replace("/", "").upper()[:20],
                    stock_quantity=100,
                    category_id=category.id,
                    is_active=True
                )
                db.add(product)
                print(f"  + Added Product: {prod_name}")

    db.commit()
    print("Database seeding completed successfully.")

if __name__ == "__main__":
    create_catalog()
