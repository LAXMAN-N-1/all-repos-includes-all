from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.menu import Menu

def seed_menus():
    db = SessionLocal()
    try:
        # Clear existing menus if any
        db.query(Menu).delete()
        
        # --- Admin Menus ---
        admin_root = Menu(title="Management", icon="Layout", sort_order=0)
        db.add(admin_root)
        db.flush()
        
        menus = [
            Menu(title="Dashboard", path="/dashboard", icon="Home", parent_id=admin_root.id, sort_order=1),
            Menu(title="Orders", path="/orders", icon="ShoppingCart", parent_id=admin_root.id, sort_order=2),
            Menu(title="Products", path="/products", icon="Box", parent_id=admin_root.id, sort_order=3),
            Menu(title="Customers", path="/customers", icon="Users", parent_id=admin_root.id, sort_order=4),
            Menu(title="Invoices", path="/invoices", icon="FileText", parent_id=admin_root.id, sort_order=5),
            Menu(title="Promotions", path="/promotions", icon="Tag", parent_id=admin_root.id, sort_order=6),
            Menu(title="CMS", path="/cms", icon="FileEdit", parent_id=admin_root.id, sort_order=7),
            Menu(title="Settings", path="/settings", icon="Settings", parent_id=admin_root.id, sort_order=8),
        ]
        
        # --- Partner Menus ---
        partner_root = Menu(title="Partner Portal", icon="Briefcase", sort_order=10)
        db.add(partner_root)
        db.flush()
        
        menus.extend([
            Menu(title="My Orders", path="/partner/orders", icon="ShoppingBag", parent_id=partner_root.id, sort_order=1),
            Menu(title="Marketplace", path="/partner/marketplace", icon="Store", parent_id=partner_root.id, sort_order=2),
            Menu(title="My Profile", path="/partner/profile", icon="User", parent_id=partner_root.id, sort_order=3),
            Menu(title="Invoices", path="/partner/invoices", icon="DollarSign", parent_id=partner_root.id, sort_order=4),
        ])
        
        for menu in menus:
            db.add(menu)
            
        db.commit()
        print("✅ Menus seeded successfully!")
    except Exception as e:
        print(f"❌ Error seeding menus: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_menus()
