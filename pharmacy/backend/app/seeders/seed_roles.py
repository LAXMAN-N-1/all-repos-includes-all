from sqlalchemy.orm import Session
from app.models.role import Role

def seed_roles(db: Session):
    """Seed default system roles"""
    roles_data = [
        # Platform
        {
            "name": "SaaS Super Admin",
            "code": "SAAS_SUPER_ADMIN",
            "description": "Platform Owner with full access",
            "is_system_role": True
        },
        # Organization
        {
            "name": "Organization Admin",
            "code": "ORG_ADMIN",
            "description": "Hospital/Chain Owner",
            "is_system_role": True
        },
        {
            "name": "Organization Manager",
            "code": "ORG_MANAGER",
            "description": "Operations Head",
            "is_system_role": True
        },
        # Store
        {
            "name": "Store Manager",
            "code": "STORE_MANAGER",
            "description": "Branch Manager",
            "is_system_role": True
        },
        {
            "name": "Pharmacist",
            "code": "PHARMACIST",
            "description": "Dispensing Staff",
            "is_system_role": True
        },
        {
            "name": "Cashier",
            "code": "CASHIER",
            "description": "Billing Staff",
            "is_system_role": True
        },
        # Clinical
        {
            "name": "Doctor",
            "code": "DOCTOR",
            "description": "Medical Practitioner",
            "is_system_role": True
        },
        {
            "name": "Nurse",
            "code": "NURSE",
            "description": "Nursing Staff",
            "is_system_role": True
        },
        {
            "name": "Lab Technician",
            "code": "LAB_TECHNICIAN",
            "description": "Pathology Staff",
            "is_system_role": True
        },
        # Patient
        {
            "name": "Patient",
            "code": "PATIENT",
            "description": "End User / Customer",
            "is_system_role": True
        }
    ]
    
    for role_data in roles_data:
        existing = db.query(Role).filter(Role.code == role_data["code"]).first()
        if not existing:
            role = Role(**role_data)
            db.add(role)
    
    db.commit()
    print(f"  [OK] Seeded {len(roles_data)} roles")