from .base_model import BaseModel
from .organization_m import Organization
from .branch_m import Branch
from .department_m import Department
from .user_m import User
from .role_m import Role
from .role_right_m import RoleRight
from .menu_m import Menu
from .attachment_m import Attachment
from .audit_log_m import AuditLog
from .settings_m import Settings
from app.models.permission_m import Permission
from app.models.role_permission_m import RolePermission
from app.models.menu_permission_m import MenuPermission
# EVENT + Category must be imported here
from .category_m import Category
from .event_m import Event
from .event_category_m import EventCategory
from .vendor_m import Vendor
from .vendor_payment_m import VendorPayment
from .vendor_bid_m import VendorBid
from .vendor_category_m import VendorCategory
from .vendor_order_m import VendorOrder
from .event_type_m import EventType
from .event_manager_profile_m import EventManagerProfile
from .service_m import Service
from .vendor_notification_m import VendorNotification
from .review_m import Review
from .chat_m import Chat, Message
# DO NOT IMPORT vendor models here !!
# They auto-register because routes import them and SQLAlchemy discovers them.

__all__ = [
    "BaseModel",
    "Organization",
    "Branch",
    "Department",
    "User",
    "Role",
    "RoleRight",
    "Menu",
    "Attachment",
    "AuditLog",
    "Settings",
    "Category",
    "Event",
    "EventCategory",
    "Permission",
    "RolePermission",
    "MenuPermission",
    "Vendor",
    "VendorPayment",
    "VendorBid",
    "VendorCategory",
    "VendorOrder",
    "EventType",
    "EventManagerProfile",
    "Service",
    "VendorNotification",
    "Review",
    "Chat",
    "Message"
]
