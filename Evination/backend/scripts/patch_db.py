import sqlite3

def patch_db():
    conn = sqlite3.connect('eventifi.db')
    cursor = conn.cursor()
    
    columns_to_add = [
        ("services_offered", "JSON DEFAULT '[]'"),
        ("base_price", "FLOAT DEFAULT 0.0"),
        ("rating", "FLOAT DEFAULT 0.0"),
        ("is_verified", "BOOLEAN DEFAULT 0"),
        ("portfolio_images", "JSON DEFAULT '[]'")
    ]
    
    for col_name, col_def in columns_to_add:
        try:
            cursor.execute(f"ALTER TABLE vendors ADD COLUMN {col_name} {col_def}")
            print(f"✅ Added column: {col_name}")
        except sqlite3.OperationalError:
            print(f"⚠️ Column {col_name} already exists.")
            
    conn.commit()
    conn.close()
    print("✨ Database patch completed.")

if __name__ == "__main__":
    patch_db()
