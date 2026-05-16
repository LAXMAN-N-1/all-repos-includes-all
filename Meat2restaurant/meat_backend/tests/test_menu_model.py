import sys
import os

# Add project root to path
sys.path.append(os.getcwd())

from app.db.session import SessionLocal
from app.models.menu import Menu

def test_menu_model():
    print("🚀 Testing Menu Model Implementation...")
    db = SessionLocal()
    
    test_title = "Test Menu Item"
    test_perm = "test.view"
    
    try:
        # 1. Create
        print("\n1. Creating Menu Item...")
        menu_item = Menu(
            title=test_title,
            path="/test",
            icon="TestIcon",
            sort_order=1,
            required_permission=test_perm
        )
        db.add(menu_item)
        db.commit()
        db.refresh(menu_item)
        
        print(f"✅ Created Menu Item ID: {menu_item.id}")
        
        # 2. Retrieve & Verify
        print("\n2. Verifying Data...")
        fetched_item = db.query(Menu).filter(Menu.id == menu_item.id).first()
        
        if not fetched_item:
            print("❌ Failed to fetch menu item!")
            return
            
        if fetched_item.title != test_title:
             print(f"❌ Title mismatch! Expected {test_title}, got {fetched_item.title}")
             
        if fetched_item.required_permission != test_perm:
             print(f"❌ Permission mismatch! Expected {test_perm}, got {fetched_item.required_permission}")
             
        print(f"✅ Data verified: Title='{fetched_item.title}', Permission='{fetched_item.required_permission}'")
        
        # 3. Cleanup
        print("\n3. Cleaning up...")
        db.delete(fetched_item)
        db.commit()
        print("✅ Cleanup complete.")
        
        print("\n🎉 MENU MODEL TEST PASSED SUCCESSFULLY!")
        
    except Exception as e:
        print(f"\n❌ Error during test: {str(e)}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    test_menu_model()
