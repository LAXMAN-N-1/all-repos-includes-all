# Import all the models, so that Base has them before being
# imported by Alembic
from app.db.base_class import Base  # noqa
from app.models.user import User  # noqa
from app.features.customers.models import Customer, Membership, MembershipPlan, CustomerGroup, Location  # noqa
from app.features.cms.models.cms import WebPage, BlogPost, Recipe, FAQ  # noqa
from app.features.catalog.models import Category, Attribute, AttributeValue, TaxTemplate, Product, ProductVariant, PartnerPrice  # noqa
from app.features.orders.models import Order, OrderItem, OrderStatusUpdate, Invoice, CombinedInvoice, Payment, Shipment, GiftCard  # noqa
from app.features.orders.models.recurring_order import RecurringOrder, RecurringOrderItem  # noqa
from app.features.orders.models.order_issue import OrderIssue  # noqa
from app.models.promotion import Promotion  # noqa
from app.models.settings import Configuration, ShippingMethod, DeliveryZone, ApiAccessKey, SettingsActivity  # noqa
from app.models.menu import Menu  # noqa
from app.models.notification import Notification  # noqa
from app.models.whatsapp import WhatsAppSession  # noqa
from app.features.inventory.models.supplier import Supplier  # noqa
from app.features.inventory.models.purchase_order import PurchaseOrder, PurchaseOrderItem  # noqa
from app.features.catalog.models.storefront import ServiceLocation, BirthdayClubEntry, NewsletterSubscription  # noqa
from app.features.stores.models.store import (  # noqa
    Store, StoreTiming, StoreSpecialHours, StoreService,
    StoreDeliveryZone, StoreWhatsappConfig, StoreMedia, StoreStaff, StoreAuditLog
)
from app.models.admin_models import (  # noqa
    AdminRole, AdminRolePermission, AdminActivityLog,
    AdminLoginHistory, AdminRefreshToken
)
