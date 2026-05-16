from .catalog import (
    CategoryOut, CategoryCreate, CategoryUpdate,
    AttributeOut, AttributeCreate, AttributeUpdate,
    AttributeValueOut, AttributeValueCreate, AttributeValueUpdate
)
from .product import (
    Product, ProductCreate, ProductUpdate,
    ProductVariant, ProductVariantCreate, ProductVariantUpdate
)
from .partner_pricing import (
    PartnerPrice, PartnerPriceCreate, PartnerPriceUpdate
)

# Compatibility Aliases
Category = CategoryOut
Attribute = AttributeOut
AttributeValue = AttributeValueOut
