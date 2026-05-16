# Role-Based Access Control (RBAC) Definitions

# 1. Defined Roles
ROLE_SUPER_ADMIN = "super_admin"
ROLE_ADMIN_MANAGER = "admin_manager"
ROLE_ORDER_MANAGER = "order_manager"
ROLE_ACCOUNTANT = "accountant"
ROLE_CUSTOMER_SUPPORT = "customer_support"
ROLE_INVENTORY_MANAGER = "inventory_manager"
ROLE_CONTENT_MANAGER = "content_manager"
ROLE_DELIVERY_MANAGER = "delivery_manager"
ROLE_DELIVERY_PERSONNEL = "delivery_personnel"
ROLE_CUSTOMER = "customer"

# 2. Permission Constants
# Format: "resource.action"

# User Management (Admin Users)
PERM_ADMIN_MANAGE = "admin.manage"      # Create, edit, delete admin users
PERM_ADMIN_VIEW = "admin.view"          # View admin lists

# Customer Management
PERM_CUSTOMER_SELF = "customer.self"    # Self-service access
PERM_CUSTOMER_VIEW = "customer.view"
PERM_CUSTOMER_MANAGE = "customer.manage" # Create, edit, full control
PERM_CUSTOMER_CREDIT = "customer.credit" # Approve credit limits
PERM_CUSTOMER_FINANCIAL = "customer.financial" # View financial details

# Order Management
PERM_ORDER_VIEW = "order.view"
PERM_ORDER_MANAGE = "order.manage"      # Edit, cancel, change status
PERM_ORDER_APPROVE = "order.approve"    # Verify/Approve orders
PERM_ORDER_ASSIGN = "order.assign"      # Assign delivery

# Product & Inventory
PERM_PRODUCT_VIEW = "product.view"
PERM_PRODUCT_MANAGE = "product.manage"  # Edit details, pricing
PERM_INVENTORY_VIEW = "inventory.view"
PERM_INVENTORY_MANAGE = "inventory.manage" # Adjust stock

# Finance & Invoices
PERM_FINANCE_VIEW = "finance.view"
PERM_FINANCE_MANAGE = "finance.manage"  # Manage invoices, payments
PERM_FINANCE_REPORT = "finance.report"  # Access sensitive reports

# Delivery
PERM_DELIVERY_VIEW = "delivery.view"
PERM_DELIVERY_MANAGE = "delivery.manage"

# Support
PERM_TICKET_VIEW = "ticket.view"
PERM_TICKET_MANAGE = "ticket.manage"

# Content & Marketing
PERM_CONTENT_MANAGE = "content.manage"
PERM_MARKETING_MANAGE = "marketing.manage"

# System
PERM_SYSTEM_SETTINGS = "system.settings"
PERM_AUDIT_LOGS = "system.audit"

# 3. Role Permission Mappings
ROLE_PERMISSIONS = {
    ROLE_SUPER_ADMIN: [
        "*", # All permissions
    ],
    ROLE_ADMIN_MANAGER: [
        PERM_CUSTOMER_MANAGE, PERM_ORDER_MANAGE, PERM_ORDER_APPROVE,
        PERM_DELIVERY_MANAGE, PERM_FINANCE_MANAGE, PERM_PRODUCT_MANAGE,
        PERM_INVENTORY_MANAGE, PERM_TICKET_MANAGE, PERM_MARKETING_MANAGE,
        PERM_ADMIN_VIEW # Manage lower admins only (needs logic)
    ],
    ROLE_ORDER_MANAGER: [
        PERM_ORDER_VIEW, PERM_ORDER_APPROVE, PERM_ORDER_MANAGE,
        PERM_ORDER_ASSIGN, PERM_CUSTOMER_VIEW, PERM_PRODUCT_VIEW,
        PERM_INVENTORY_VIEW, PERM_DELIVERY_VIEW
    ],
    ROLE_ACCOUNTANT: [
        PERM_FINANCE_VIEW, PERM_FINANCE_MANAGE, PERM_FINANCE_REPORT,
        PERM_CUSTOMER_FINANCIAL, PERM_ORDER_VIEW, PERM_INVENTORY_VIEW
    ],
    ROLE_CUSTOMER_SUPPORT: [
        PERM_TICKET_VIEW, PERM_TICKET_MANAGE, PERM_CUSTOMER_VIEW,
        PERM_ORDER_VIEW, PERM_PRODUCT_VIEW, PERM_DELIVERY_VIEW
    ],
    ROLE_INVENTORY_MANAGER: [
        PERM_INVENTORY_VIEW, PERM_INVENTORY_MANAGE, PERM_PRODUCT_VIEW,
        PERM_ORDER_VIEW
    ],
    ROLE_CONTENT_MANAGER: [
        PERM_PRODUCT_VIEW, PERM_CONTENT_MANAGE, PERM_MARKETING_MANAGE
    ],
    ROLE_DELIVERY_MANAGER: [
        PERM_DELIVERY_VIEW, PERM_DELIVERY_MANAGE, PERM_ORDER_ASSIGN,
        PERM_ORDER_VIEW
    ],
    ROLE_DELIVERY_PERSONNEL: [
        "delivery.app_access" # Basic access to mobile app
    ],
    ROLE_CUSTOMER: [
        PERM_CUSTOMER_SELF, PERM_PRODUCT_VIEW, PERM_ORDER_MANAGE
    ]
}

def get_role_permissions(role: str) -> list[str]:
    return ROLE_PERMISSIONS.get(role, [])
