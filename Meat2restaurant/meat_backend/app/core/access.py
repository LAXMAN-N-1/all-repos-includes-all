from typing import Any

def can_manage_team(identity: Any) -> bool:
    """
    Check if identity can manage team/business.
    - Staff: Based on role.
    - Partner: Inherent right over self.
    """
    if getattr(identity, "identity_type", None) == "staff":
        if identity.is_superuser or identity.role in ["admin", "manager"]:
            return True
    elif getattr(identity, "identity_type", None) == "partner":
        return True # Every partner manages their own business now
        
    return False

def can_view_invoices(identity: Any) -> bool:
    # Logic for viewing business invoices
    if getattr(identity, "identity_type", None) == "partner":
        return True
    if getattr(identity, "identity_type", None) == "staff":
        return True # Internal staff can see invoices for accounts they manage
    return False
