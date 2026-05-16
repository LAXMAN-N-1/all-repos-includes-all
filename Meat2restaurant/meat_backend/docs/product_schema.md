# Database Schema: Products Table

This document provides a technical overview of the `products` table, which serves as the core inventory and pricing engine for the B2B Meat Platform.

## 1. Table Schema: `products`

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **`id`** | Integer | Primary Key | Unique system identifier. |
| **`name`** | String(255) | Indexed, Not Null | Public and internal display name. |
| **`description`** | Text | Nullable | Marketing description and technical specs. |
| **`price`** | Float | Not Null | **Retail Price**: Standard price for non-B2B users. |
| **`wholesale_price`** | Float | Nullable | **B2B Price**: Base price for verified partners. |
| **`sku`** | String(100) | Unique, Indexed | Stock Keeping Unit (e.g., `BF-RBY-001`). |
| **`image_url`** | String(500) | Nullable | Path to the product image asset. |
| **`stock_quantity`** | Integer | Default: 0 | Current physical inventory count. |
| **`unit`** | String(50) | Default: "unit" | Unit of measure (Localized: **lbs**, Case, etc.). |
| **`min_order_quantity`**| Integer | Default: 1 | Minimum order threshold for B2B portal. |
| **`volume_tiers`** | JSON | Nullable | Tiered pricing rules (e.g. `{"10": 40.0, "50": 35.0}`). |
| **`category_id`** | Integer | Foreign Key | Links to the `categories` table. |
| **`is_active`** | Boolean | Default: True | Controls visibility in catalogs. |
| **`created_at`** | DateTime | Mixin | Database record creation timestamp. |
| **`updated_at`** | DateTime | Mixin | Record last modification timestamp. |

---

## 2. Relationship Model (ERD)

The `Product` model is linked to several critical modules:

- **Categories**: `Many-to-One` relationship. Each product belongs to one specific category (e.g., Beef, Poultry).
- **Product Variants**: `One-to-Many` relationship. A single product SKU can have multiple variants (e.g., *French Trimmed* vs *Primal Cut*).
- **Partner Pricing**: External link. High-priority "Contract Prices" for specific customers override the `wholesale_price`.
- **Order Items**: `One-to-Many`. Historical record tracking every order that contains this product.

---

## 3. Business Logic Implementation

### US Localization
The `unit` field has been localized for the United States market. All weight-based calculations and display units default to **lbs** (pounds).

### Tiered Pricing (Volume Discounts)
The `volume_tiers` JSON field allows the system to automatically apply bulk discounts.
*Example*: If a product is $45.00/lb, the JSON `{"10": 42.0}` means the price drops to $42.00/lb if the customer buys 10 or more.

### Inventory Safeguards
The Stock Predictor service monitors `stock_quantity` to provide "Days Remaining" analytics based on historical order frequency.
