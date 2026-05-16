from enum import Enum

class OrderStatus(str, Enum):
    """Order lifecycle statuses"""
    PENDING = "pending"
    CONFIRMED = "confirmed"
    PACKED = "packed"
    READY_FOR_PICKUP = "ready_for_pickup"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class PrescriptionStatus(str, Enum):
    """Prescription validation statuses"""
    PENDING = "pending"
    PROCESSING = "processing"
    VERIFIED = "verified"
    REJECTED = "rejected"

class PaymentStatus(str, Enum):
    """Payment statuses"""
    PENDING = "pending"
    PAID = "paid"
    REFUNDED = "refunded"
    FAILED = "failed"

class PaymentMethod(str, Enum):
    """Payment methods"""
    CASH_ON_PICKUP = "cash_on_pickup"
    ONLINE = "online"
    CARD = "card"
    UPI = "upi"

# Permission constants
class Permissions:
    """Permission codes for RBAC"""
    # Users
    USER_CREATE = "user.create"
    USER_READ = "user.read"
    USER_UPDATE = "user.update"
    USER_DELETE = "user.delete"
    
    # Stores
    STORE_CREATE = "store.create"
    STORE_READ = "store.read"
    STORE_UPDATE = "store.update"
    STORE_DELETE = "store.delete"
    
    # Inventory
    INVENTORY_CREATE = "inventory.create"
    INVENTORY_READ = "inventory.read"
    INVENTORY_UPDATE = "inventory.update"
    INVENTORY_DELETE = "inventory.delete"
    
    # Orders
    ORDER_CREATE = "order.create"
    ORDER_READ = "order.read"
    ORDER_UPDATE = "order.update"
    ORDER_DELETE = "order.delete"
    
    # Prescriptions
    PRESCRIPTION_READ = "prescription.read"
    PRESCRIPTION_VERIFY = "prescription.verify"
    PRESCRIPTION_REJECT = "prescription.reject"
    
    # Analytics
    ANALYTICS_VIEW = "analytics.view"
    ANALYTICS_EXPORT = "analytics.export"
    
    # Dashboard
    DASHBOARD_HQ = "dashboard.hq"
    DASHBOARD_STORE = "dashboard.store"
    DASHBOARD_PHARMACIST = "dashboard.pharmacist"