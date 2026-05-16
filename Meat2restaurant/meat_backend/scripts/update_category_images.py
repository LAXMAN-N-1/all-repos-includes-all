import os
import sys
from dotenv import load_dotenv

# Load env variables
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

# Add backend directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.db.session import SessionLocal
from app.models.catalog import Category

def update_category_images():
    db = SessionLocal()
    categories_dir = os.path.join(os.path.dirname(__file__), "static", "categories")
    
    if not os.path.exists(categories_dir):
        print("Categories static directory not found.")
        return

    # Map filename prefixes to their exact category names in DB
    category_map = {
        "beef": "🥩 BEEF",
        "pork": "🐷 PORK",
        "poultry": "🐔 POULTRY",
        "lamb": "🐑 LAMB & MUTTON",
        "goat": "🐐 GOAT",
        "game": "🦌 GAME MEAT",
        "seafood": "🐟 SEAFOOD",
        "plant": "🌿 PLANT-BASED",
        "deli": "🥪 DELI MEAT / CHARCUTERIE"
    }

    print("Scanning image files in /static/categories/...")
    
    for filename in os.listdir(categories_dir):
        if not filename.endswith(".png"):
            continue
            
        print(f"Found image: {filename}")
        
        # Try to match to category
        matched_prefix = None
        for prefix in category_map.keys():
            if filename.startswith(f"{prefix}_category"):
                matched_prefix = prefix
                break
                
        if matched_prefix:
            db_cat_name = category_map[matched_prefix]
            category = db.query(Category).filter(Category.name == db_cat_name).first()
            if category:
                # Assuming backend URL is handled dynamically on frontend, or we store relative path
                static_url = f"/static/categories/{filename}"
                category.image_url = static_url
                db.add(category)
                print(f" -> Linked to DB Category '{db_cat_name}' with URL {static_url}")
            else:
                print(f" -> DB Category '{db_cat_name}' NOT FOUND")

    db.commit()
    print("Category image linking completed successfully.")

if __name__ == "__main__":
    update_category_images()
