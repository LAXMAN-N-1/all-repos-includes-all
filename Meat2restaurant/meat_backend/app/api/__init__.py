"""
API Router
"""
from fastapi import APIRouter

from app.api.endpoints import (
    auth, users, 
    whatsapp, promotions, settings, 
    reports, analytics, test_history, vault, notifications, menus,
    stripe_payments, admin_users, admin_roles, admin_activity, admin_login_history,
    dealer
)
from app.features.cms.api import endpoints as cms_endpoints
from app.features.catalog.api.catalog import router as catalog_router
from app.features.catalog.api.categories import router as categories_router
from app.features.catalog.api.partner_pricing import router as partner_pricing_router
from app.features.catalog.api.products import router as products_router

from app.features.orders.api.orders import router as orders_router
from app.features.orders.api.invoices import router as invoices_router
from app.features.orders.api.payments import router as payments_router
from app.features.orders.api.sales import router as sales_router
from app.features.orders.api.recurring_orders import router as recurring_orders_router
from app.features.orders.api.order_issues import router as order_issues_router

from app.features.customers.api.customers import router as customers_router
from app.features.customers.api.customer_groups import router as customer_groups_router
from app.features.customers.api.locations import router as locations_router
from app.features.inventory.api.inventory import router as inventory_router

api_router = APIRouter()

# Core Authentication & User Management
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(users.router, prefix="/users", tags=["users"])

# Customers Feature
api_router.include_router(customers_router, prefix="/customers", tags=["customers"])
api_router.include_router(customer_groups_router, prefix="/customer-groups", tags=["customer-groups"])
api_router.include_router(locations_router, prefix="/locations", tags=["locations"])

# Catalog Feature
api_router.include_router(products_router, prefix="/products", tags=["products"])
api_router.include_router(categories_router, prefix="/categories", tags=["categories"])
api_router.include_router(catalog_router, prefix="/catalog", tags=["catalog"])
api_router.include_router(partner_pricing_router, prefix="/partner-pricing", tags=["partner-pricing"])

# Inventory Feature
api_router.include_router(inventory_router, prefix="/inventory", tags=["inventory"])

# Orders Feature
api_router.include_router(orders_router, prefix="/orders", tags=["orders"])
api_router.include_router(invoices_router, prefix="/invoices", tags=["invoices"])
api_router.include_router(payments_router, prefix="/payments", tags=["payments"])
api_router.include_router(sales_router, prefix="/sales", tags=["sales"])
api_router.include_router(recurring_orders_router, prefix="/recurring-orders", tags=["recurring-orders"])
api_router.include_router(order_issues_router, prefix="/order-issues", tags=["order-issues"])

from app.features.catalog.api.storefront import router as storefront_router
from app.features.catalog.api.customer_storefront import router as customer_storefront_router

# CMS Feature
api_router.include_router(cms_endpoints.router, prefix="/cms", tags=["cms"])

# Utility & Management Endpoints
api_router.include_router(promotions.router, prefix="/promotions", tags=["promotions"])
api_router.include_router(stripe_payments.router, prefix="/stripe", tags=["stripe"])
api_router.include_router(whatsapp.router, prefix="/whatsapp", tags=["whatsapp"])
api_router.include_router(settings.router, prefix="/settings", tags=["settings"])

# Public Storefront (No Auth)
api_router.include_router(storefront_router, prefix="/store", tags=["storefront"])

# Authenticated Customer Storefront
api_router.include_router(customer_storefront_router, prefix="/store/customer", tags=["customer-storefront"])
api_router.include_router(admin_users.router, prefix="/admin-users", tags=["admin-users"])
api_router.include_router(admin_roles.router, prefix="/admin-roles", tags=["admin-roles"])
api_router.include_router(admin_activity.router, prefix="/admin-activity-logs", tags=["admin-activity-logs"])
api_router.include_router(admin_login_history.router, prefix="/admin-login-history", tags=["admin-login-history"])
api_router.include_router(dealer.router, prefix="/dealer", tags=["dealer"])

