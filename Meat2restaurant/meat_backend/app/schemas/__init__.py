from .token import Token, TokenPayload
from .user import User, UserCreate, UserUpdate
from app.features.customers.schemas.customer import (
    Customer, CustomerCreate, CustomerUpdate,
    Membership, MembershipCreate, MembershipUpdate,
    MembershipPlan, MembershipPlanCreate, MembershipPlanUpdate,
    PasswordResetRequest, PasswordResetConfirm,
    CustomerRegister, CustomerApply, CustomerApprove,
    CustomerUpdatePartner, CustomerCreateAdmin, CustomerUpdateAdmin,
    CustomerBulkImport, CustomerBulkImportResult
)
from app.features.customers.schemas.customer_group import (
    CustomerGroup, CustomerGroupCreate, CustomerGroupUpdate, CustomerGroupInDBBase
)
from app.features.catalog.schemas.product import (
    Product, ProductCreate, ProductUpdate,
    ProductVariant, ProductVariantCreate, ProductVariantUpdate
)
from app.features.catalog.schemas.review import (
    ProductReviewCreate, ProductReviewUpdateStatus, ProductReviewResponse
)
from app.features.orders.schemas.order import (
    Order, OrderCreate, OrderUpdate,
    OrderItem, OrderItemCreate, OrderItemUpdate,
    OrderStatusUpdate, OrderStatusUpdateCreate
)
from app.features.orders.schemas.invoice import (
    Invoice, InvoiceCreate, InvoiceUpdate, 
    CombinedInvoice, CombinedInvoiceCreate,
    ConsolidatedInvoiceRequest, CreditNote, CreditNoteCreate,
    Payment, PaymentCreate, PaymentUpdate
)
from app.features.catalog.schemas.partner_pricing import PartnerPrice, PartnerPriceCreate, PartnerPriceUpdate
from app.features.customers.schemas.location import Location, LocationCreate, LocationUpdate
from app.features.orders.schemas.sales_extras import (
    ShipmentOut, ShipmentCreate, ShipmentUpdate,
    GiftCardOut, GiftCardCreate, GiftCardUpdate, GiftCardRedeem
)
from app.features.catalog.schemas.catalog import (
    CategoryOut, CategoryCreate, CategoryUpdate,
    AttributeOut, AttributeCreate, AttributeUpdate, 
    AttributeValueOut, AttributeValueCreate, AttributeValueUpdate
)
from .promotion import PromotionCreate, PromotionUpdate, PromotionOut
from .settings import (
    ConfigUpdate, ConfigOut,
    ShippingMethodCreate, ShippingMethodUpdate, ShippingMethodOut,
    DeliveryZoneCreate, DeliveryZoneUpdate, DeliveryZoneOut,
    ReportsMetric, ReportsInsights, NotificationPreferences,
    TaxPreferences, PaymentPreferences, SettingsOverview,
    SettingsActivityOut, ApiAccessKeyCreate, ApiAccessKeyOut,
    ApiAccessKeyCreateResult, RoleDefinitionOut
)
from app.features.cms.schemas.cms import (
    WebPageCreate, WebPageUpdate, WebPageOut, WebPageVersionOut,
    BlogPostCreate, BlogPostUpdate, BlogPostOut, BlogPostVersionOut,
    RecipeCreate, RecipeUpdate, RecipeOut, 
    RecipeIngredientCreate, RecipeIngredientOut,
    RecipeStepCreate, RecipeStepOut,
    RecipeNutritionCreate, RecipeNutritionOut,
    FAQCreate, FAQUpdate, FAQOut,
    LegalDocumentCreate, LegalDocumentUpdate, LegalDocumentOut, LegalDocumentVersionOut,
    AboutStoreCreate, AboutStoreUpdate, AboutStoreOut,
    TeamMemberCreate, TeamMemberUpdate, TeamMemberOut,
    CertificationCreate, CertificationOut,
    AwardCreate, AwardOut,
    TimelineEventCreate, TimelineEventOut
)
from .vault import WalletTransaction, WalletTransactionCreate, WalletDeposit, WalletBalance
from .notification import Notification as NotificationOut, NotificationCreate, NotificationUpdate
from .menu import Menu, MenuCreate, MenuUpdate
from app.features.orders.schemas.recurring_order import (
    RecurringOrderCreate, RecurringOrderUpdate, RecurringOrderOut,
    RecurringOrderItemCreate, RecurringOrderItemOut
)
from app.features.orders.schemas.order_issue import (
    OrderIssueCreate, OrderIssueUpdate, OrderIssueOut
)
from app.features.stores.schemas.store import (
    StoreCreate, StoreUpdate, StoreOut, StoreSummaryOut,
    StoreTimingCreate, StoreTimingOut,
    StoreSpecialHoursCreate, StoreSpecialHoursOut,
    StoreServiceCreate, StoreServiceOut,
    StoreDeliveryZoneCreate, StoreDeliveryZoneUpdate, StoreDeliveryZoneOut,
    StoreWhatsappConfigCreate, StoreWhatsappConfigOut,
    StoreMediaCreate, StoreMediaOut,
    StoreStaffCreate, StoreStaffOut,
    PaginatedStoresResponse, StoreStatusUpdate, WhatsappBranchOut
)

# Compatibility Aliases
Shipment = ShipmentOut
GiftCard = GiftCardOut
Category = CategoryOut
Attribute = AttributeOut
AttributeValue = AttributeValueOut
Notification = NotificationOut
Recipe = RecipeOut
FAQ = FAQOut
BlogPost = BlogPostOut
WebPage = WebPageOut
LegalDocument = LegalDocumentOut
AboutStore = AboutStoreOut
TeamMember = TeamMemberOut
Certification = CertificationOut
Award = AwardOut
TimelineEvent = TimelineEventOut
