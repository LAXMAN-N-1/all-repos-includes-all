import httpx
import json
import random
import string
import traceback
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, Request, Query
from fastapi.responses import PlainTextResponse
from sqlalchemy import func, or_
from sqlalchemy.orm import Session
from app.api import deps
from app.core.config import settings
from app import models
from app.services.whatsapp import whatsapp_service
from app.features.stores.models.store import Store
from app.features.catalog.models.catalog import Category
from app.services.pdf_generator import pdf_generator
from app.services.scheduler import notification_scheduler
from app.core import stripe_utils
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

# ═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE STRINGS
# ═══════════════════════════════════════════════════════════════════════════════
STRINGS = {
    "en": {
        # ─── Welcome ───
        "welcome": (
            "👋 *Welcome to Meat2Restaurant!*\n\n"
            "I am your *Order Assistant*. I will help you browse "
            "fresh meat products and place your order."
        ),
        "welcome_back": (
            "👋 *Welcome back, {name}!*\n"
            "📍 Your store: *{store}* ✅"
        ),
        "store_select": "📍 *Select your store location:*",

        # ─── Reorder ───
        "reorder_prompt": (
            "⚡ *Quick Reorder Available!*\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "Your frequently ordered items:\n\n"
            "{top_items}\n\n"
            "💰 Estimated Total: *₹{total:.2f}*"
        ),

        # ─── Catalogs ───
        "catalog_header": (
            "🌿 *{store} — Fresh Products*\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "Select a category to browse:"
        ),
        "category_header": (
            "{emoji} *{catalog} — Select Type*\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "Choose a cut or style:"
        ),
        "product_list_header": (
            "{emoji} *{category} Products*\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "Tap a product to add to cart:"
        ),
        "no_products": "😔 No products available in this category right now.",

        # ─── Cart ───
        "added_to_cart": (
            "✅ *Added to Cart!*\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "{emoji} *{name}*\n"
            "📦 {qty} box(es) = {weight} lbs\n"
            "💰 ₹{total:.2f}\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
            "🛒 *Current Cart:*\n{cart_summary}\n\n"
            "Would you like to add more?"
        ),
        "qty_control": (
            "🛍️ *{name}*\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "📦 Selected: *{qty} box(es)* ({weight} lbs)\n"
            "💰 Total: *₹{total:.2f}*"
        ),
        "cart_header": "🛒 *Your Cart — {store}*\n━━━━━━━━━━━━━━━━━━━━━━━━━",
        "cart_footer": (
            "\n━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "📦 Items: *{count}* | Weight: *{weight} lbs*\n"
            "💵 Subtotal: *₹{subtotal:.2f}*\n"
            "🏷️ Tax (8.25%): *₹{tax:.2f}*\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "💰 *Total: ₹{total:.2f}*"
        ),
        "cart_empty": "🛒 Your cart is empty!\nBrowse products to start ordering.",

        # ─── Checkout ───
        "pickup_only": (
            "🏪 *Order Fulfillment*\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "Store Pickup is available.\n\n"
            "📅 *Select your pickup date:*"
        ),
        "payment_header": (
            "💳 *Payment Method*\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "Select your preferred payment option:"
        ),

        # ─── Order Confirmed ───
        "order_confirmed": (
            "🎉 *Order Confirmed!*\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "🆔 Order: *{order_id}*\n"
            "📍 Store: *{store}*\n"
            "📅 Pickup: *{pickup_date}*\n"
            "👤 Name: *{name}*\n"
            "💳 Payment: *{payment}*\n"
            "💰 Total: *₹{total:.2f}*\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
            "📄 Your invoice is attached below!"
        ),
        "thank_you": (
            "🙏 *Thank you for shopping with Meat2Restaurant!* 🥩❤️\n\n"
            "Your order will be ready for pickup on your selected date.\n"
            "See you soon! 😊"
        ),
        "order_cancelled": "❌ Order has been cancelled.",
        "error_generic": "⚠️ Something went wrong. Type *Hi* to restart.",
    }
}

def t(key, **kwargs):
    s = STRINGS["en"].get(key, key)
    return s.format(**kwargs) if kwargs else s


# ═══════════════════════════════════════════════════════════════════════════════
# STORES & CATALOG — FETCHED FROM DATABASE
# ═══════════════════════════════════════════════════════════════════════════════

# Emoji mapping for category names
_CATEGORY_EMOJIS = {
    "chicken": "🐔", "goat": "🐐", "beef": "🥩", "mutton": "🐑",
    "seafood": "🐟", "frozen": "❄️", "whole boxes": "📦", "lamb": "🐑",
}

def _emoji_for(name: str) -> str:
    n = name.lower()
    for kw, em in _CATEGORY_EMOJIS.items():
        if kw in n:
            return em
    return "🥩"

def get_stores_from_db(db: Session) -> list:
    """Fetch active stores from the Store Location Master."""
    stores = db.query(Store).filter(Store.status == "active").order_by(Store.display_order).all()
    if not stores:
        return [{"id": 0, "name": "Dallas, TX", "label": "Dallas"}]
    return [{"id": s.id, "name": f"{s.city or s.name}, {s.state or ''}".strip(", "), "label": s.name} for s in stores]

def get_catalog_defs_from_db(db: Session) -> list:
    """Fetch top-level categories (no parent) from DB as catalog definitions."""
    cats = db.query(Category).filter(Category.parent_id == None, Category.is_active == True).all()
    if not cats:
        return [{"id": "chicken", "name": "Chicken", "emoji": "🐔", "keywords": ["chicken"], "db_id": None}]
    result = []
    for c in cats:
        name_lower = c.name.lower()
        keywords = [name_lower]
        
        # Expand keywords for common items
        if "chicken" in name_lower: keywords.extend(["bird", "poultry"])
        if "mutton" in name_lower or "goat" in name_lower or "lamb" in name_lower:
            keywords.extend(["mutton", "goat", "lamb", "sheep"])
        if "seafood" in name_lower or "fish" in name_lower:
            keywords.extend(["fish", "shrimp", "seafood", "prawn"])
            
        cat_id = name_lower.replace(" ", "_")
        if c.id == 48: cat_id = "test_1rs"
            
        result.append({
            "id": cat_id,
            "name": c.name,
            "emoji": _emoji_for(c.name),
            "keywords": list(set(keywords)),
            "db_id": c.id,
        })
    
    # Update global if possible (best effort for simple workers)
    global CATALOG_DEFS
    CATALOG_DEFS = result
    
    return result

# Fallback static values (only used if DB is empty)
STORES = ["Dallas, TX", "Austin, TX"]
CATALOG_DEFS = []

WEIGHT_PER_BOX = 40  # lbs
TAX_RATE = 0.0825


# ═══════════════════════════════════════════════════════════════════════════════
# SESSION MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════════
_sessions = {}

def _blank_session():
    return {
        "state": "welcome",
        "store": None,
        "cart": [],
        "checkout": {},
        "browse_catalog": None,      # e.g. "chicken"
        "browse_category_id": None,  # DB category id
        "pending_item": None,
        "last_order_id": None,
    }

def get_session(phone: str) -> dict:
    if phone not in _sessions:
        _sessions[phone] = _blank_session()
    return _sessions[phone]

def save_session(phone: str, session: dict):
    _sessions[phone] = session

def clear_session(phone: str):
    _sessions[phone] = _blank_session()


# ═══════════════════════════════════════════════════════════════════════════════
# WHATSAPP SENDING HELPERS (Meta Cloud API)
# ═══════════════════════════════════════════════════════════════════════════════
BASE_URL = "https://graph.facebook.com/v18.0"

def _post(payload: dict) -> dict:
    url = f"{BASE_URL}/{settings.WHATSAPP_PHONE_NUMBER_ID}/messages"
    headers = {
        "Authorization": f"Bearer {settings.WHATSAPP_ACCESS_TOKEN}",
        "Content-Type": "application/json",
    }
    try:
        r = httpx.post(url, json=payload, headers=headers, timeout=15)
        logger.info(f"[WA] {r.status_code}: {r.text[:200]}")
        return r.json()
    except Exception as e:
        logger.error(f"[WA ERROR] {e}")
        return {}


def send_text(to: str, text: str):
    return _post({
        "messaging_product": "whatsapp",
        "to": to,
        "type": "text",
        "text": {"body": text, "preview_url": False},
    })


def send_buttons(to: str, body: str, buttons: list, footer: str = ""):
    """Send up to 3 quick-reply buttons."""
    btns = [{"type": "reply", "reply": {"id": b["id"], "title": b["title"][:20]}} for b in buttons[:3]]
    payload = {
        "messaging_product": "whatsapp",
        "to": to,
        "type": "interactive",
        "interactive": {
            "type": "button",
            "body": {"text": body},
            "action": {"buttons": btns},
        },
    }
    if footer:
        payload["interactive"]["footer"] = {"text": footer[:60]}
    return _post(payload)


def send_list(to: str, header: str, body: str, button_label: str, sections: list, footer: str = ""):
    """Send a scrollable list message."""
    payload = {
        "messaging_product": "whatsapp",
        "to": to,
        "type": "interactive",
        "interactive": {
            "type": "list",
            "header": {"type": "text", "text": header[:60]},
            "body": {"text": body},
            "action": {"button": button_label[:20], "sections": sections},
        },
    }
    if footer:
        payload["interactive"]["footer"] = {"text": footer[:60]}
    return _post(payload)


def send_document_by_url(to: str, doc_url: str, filename: str, caption: str = ""):
    """Send a document via URL (for PDF invoices)."""
    payload = {
        "messaging_product": "whatsapp",
        "to": to,
        "type": "document",
        "document": {
            "link": doc_url,
            "filename": filename,
        },
    }
    if caption:
        payload["document"]["caption"] = caption[:1024]
    return _post(payload)


# ═══════════════════════════════════════════════════════════════════════════════
# HELPER UTILITIES
# ═══════════════════════════════════════════════════════════════════════════════

def _build_cart_summary(cart: list) -> str:
    """Build a compact text summary of cart items."""
    if not cart:
        return "  (empty)"
    lines = []
    for i in cart:
        emoji = _get_product_emoji(i.get("name", ""))
        lines.append(f"  {emoji} {i['name']} — {i['qty']} box(es) — ₹{i['total']:.2f}")
    return "\n".join(lines)


def _get_product_emoji(name: str) -> str:
    """Return an appropriate emoji for a product name."""
    n = name.lower()
    if "chicken" in n: return "🐔"
    if "goat" in n: return "🐐"
    if "mutton" in n or "lamb" in n: return "🐑"
    if "beef" in n: return "🥩"
    if "fish" in n or "shrimp" in n or "seafood" in n: return "🐟"
    if "frozen" in n: return "❄️"
    return "🥩"


def _get_catalog_for_product(name: str) -> str:
    """Match a product name to a catalog id."""
    n = name.lower()
    for cat in CATALOG_DEFS:
        if any(kw in n for kw in cat["keywords"]):
            return cat["id"]
    return "general"


def _get_catalog_def(catalog_id: str, catalog_defs: list = None) -> dict:
    """Get catalog definition by id, prioritizing provided list or global."""
    source = catalog_defs if catalog_defs is not None else CATALOG_DEFS
    for c in source:
        if c["id"] == catalog_id:
            return c
    # Fallback if not found in source
    return {"id": catalog_id, "name": catalog_id.replace("_", " ").title(), "emoji": "📦", "keywords": [catalog_id.lower().replace("_", " ")], "db_id": None}


def _calc_cart_totals(cart: list) -> dict:
    """Calculate cart subtotal, tax, total, weight."""
    subtotal = sum(i["total"] for i in cart)
    weight = sum(i["weight"] for i in cart)
    tax = subtotal * TAX_RATE
    total = subtotal + tax
    return {"subtotal": subtotal, "tax": tax, "total": total, "weight": int(weight), "count": len(cart)}


def _get_public_base_url() -> str:
    """Resolve the externally reachable base URL for callbacks."""
    return (settings.PUBLIC_BASE_URL or settings.BASE_URL or "https://meat2restaurant.com").rstrip("/")


def _generate_pickup_dates() -> list:
    """Generate pickup date options for Today, Tomorrow, and next 3 days."""
    today = datetime.now()
    dates = []
    labels = ["Today", "Tomorrow"]
    for i in range(5):
        d = today + timedelta(days=i)
        label = labels[i] if i < 2 else d.strftime("%A")
        date_str = d.strftime("%b %d")
        dates.append({
            "id": f"date_{i}",
            "title": f"📅 {label}",
            "description": date_str,
        })
    return dates


# ═══════════════════════════════════════════════════════════════════════════════
# FLOW HANDLERS
# ═══════════════════════════════════════════════════════════════════════════════

# ──────────────── STEP 1-3: WELCOME & LOCATION ────────────────

def handle_welcome(to: str, session: dict, db: Session):
    """Welcome message + store selection (or auto-recognition for B2B)."""
    customer = db.query(models.Customer).filter(models.Customer.phone == to).first()

    # B2B / Returning User — Auto-recognize location
    if customer and customer.preferred_location:
        session["store"] = customer.preferred_location
        send_text(to, t("welcome_back", name=customer.name or "Partner", store=session["store"]))

        # Check for reorder suggestions (3+ completed orders)
        order_count = (
            db.query(func.count(models.Order.id))
            .filter(models.Order.customer_id == customer.id, models.Order.status == "confirmed")
            .scalar() or 0
        )

        if order_count >= 3:
            handle_reorder_suggestion(to, session, db, customer)
        else:
            handle_show_catalogs(to, session, db)

        session["state"] = "returning_welcome"
        return

    # First-time user — Welcome + Store Selection (dynamic from DB)
    send_text(to, t("welcome"))
    db_stores = get_stores_from_db(db)
    buttons = [{"id": f"store_{i}", "title": f"📍 {s['label'][:17]}"} for i, s in enumerate(db_stores[:3])]
    if not buttons:
        buttons = [{"id": "store_0", "title": "📍 Dallas"}]
    send_buttons(to, t("store_select"), buttons, footer="Meat2Restaurant — Fresh Halal Meats")
    session["_db_stores"] = db_stores  # stash for selection handler
    session["state"] = "store_select"


def handle_store_selected(to: str, session: dict, db: Session, store_index: int):
    """Store selected — save preference and show catalogs."""
    db_stores = session.get("_db_stores") or get_stores_from_db(db)
    store_info = db_stores[store_index] if store_index < len(db_stores) else db_stores[0]
    store = store_info["name"]
    session["store"] = store

    # Save preferred_location for future auto-detection
    customer = db.query(models.Customer).filter(models.Customer.phone == to).first()
    if customer:
        customer.preferred_location = store
        db.commit()

    send_text(to, f"✅ Store set to *{store}*!")
    handle_show_catalogs(to, session, db)


# ──────────────── STEP 4: REORDER SUGGESTIONS ────────────────

def handle_reorder_suggestion(to: str, session: dict, db: Session, customer):
    """Show frequently ordered items for quick reorder (real data from DB)."""
    try:
        # Get top 3 most ordered products from last 5 orders
        recent_orders = (
            db.query(models.Order.id)
            .filter(models.Order.customer_id == customer.id)
            .order_by(models.Order.id.desc())
            .limit(5)
            .subquery()
        )

        top_items_query = (
            db.query(
                models.OrderItem.product_id,
                models.Product.name,
                func.sum(models.OrderItem.quantity).label("total_qty"),
                models.Product.wholesale_price,
                models.Product.price,
            )
            .join(models.Product, models.OrderItem.product_id == models.Product.id)
            .filter(models.OrderItem.order_id.in_(db.query(recent_orders.c.id)))
            .group_by(models.OrderItem.product_id, models.Product.name, models.Product.wholesale_price, models.Product.price)
            .order_by(func.sum(models.OrderItem.quantity).desc())
            .limit(3)
            .all()
        )

        if not top_items_query:
            handle_show_catalogs(to, session, db)
            return

        # Build reorder cart items
        reorder_items = []
        lines = []
        grand_total = 0.0

        for product_id, name, total_qty, wholesale_price, price in top_items_query:
            unit_price = float(wholesale_price or price or 0)
            avg_qty = max(1, int(total_qty / 5))  # Average per order
            item_total = avg_qty * WEIGHT_PER_BOX * unit_price
            emoji = _get_product_emoji(name)
            lines.append(f"{emoji} {name} — {avg_qty} box(es)")
            grand_total += item_total
            reorder_items.append({
                "id": str(product_id),
                "name": name,
                "qty": avg_qty,
                "price_per_lb": unit_price,
                "weight": avg_qty * WEIGHT_PER_BOX,
                "total": item_total,
            })

        session["_reorder_items"] = reorder_items

        send_buttons(
            to,
            t("reorder_prompt", top_items="\n".join(lines), total=grand_total),
            [
                {"id": "reorder_confirm", "title": "✅ Order These"},
                {"id": "menu_catalog", "title": "🛒 Browse Products"},
            ],
            footer="Based on your recent orders"
        )

    except Exception as e:
        logger.error(f"[Reorder] {e}")
        handle_show_catalogs(to, session, db)


# ──────────────── STEP 5: CATALOG BROWSING (Level 1) ────────────────

def handle_show_catalogs(to: str, session: dict, db: Session = None):
    """Show top-level catalog categories from DB."""
    store = session.get("store", "Store")

    # Fetch catalogs from DB (or use cached)
    catalog_defs = get_catalog_defs_from_db(db) if db else CATALOG_DEFS
    if not catalog_defs:
        catalog_defs = [{"id": "all", "name": "All Products", "emoji": "🥩", "keywords": [], "db_id": None}]
    session["_catalog_defs"] = catalog_defs  # cache for later lookups

    # Build list rows for catalogs
    rows = []
    for cat in catalog_defs:
        rows.append({
            "id": f"catalog_{cat['id']}",
            "title": f"{cat['emoji']} {cat['name']}",
            "description": f"Browse {cat['name'].lower()} products",
        })

    send_list(
        to,
        header="🛒 Product Catalog",
        body=t("catalog_header", store=store),
        button_label="Browse Products",
        sections=[{"title": "🌿 All Categories", "rows": rows}],
        footer="Zabiha Halal Certified ✅"
    )
    session["state"] = "show_catalogs"


# ──────────────── STEP 5-6: CATEGORY BROWSING (Level 2) ────────────────

def handle_catalog_selected(to: str, session: dict, db: Session, catalog_id: str):
    """User selected a catalog (e.g. Chicken) — show sub-categories."""
    catalog_defs = session.get("_catalog_defs") or get_catalog_defs_from_db(db)
    cat_def = _get_catalog_def(catalog_id, catalog_defs)
    session["browse_catalog"] = catalog_id

    # Try to find sub-categories from DB Category table
    sub_categories = []
    
    # 1. Try by DB ID first (most reliable)
    db_id = cat_def.get("db_id")
    parent_cat = None
    if db_id:
        parent_cat = db.query(Category).filter(Category.id == db_id).first()
    
    # 2. Fallback to keyword search
    if not parent_cat:
        keywords = cat_def.get("keywords", [])
        for kw in keywords:
            parent_cat = (
                db.query(Category)
                .filter(Category.name.ilike(f"%{kw}%"), Category.parent_id == None, Category.is_active == True)
                .first()
            )
            if parent_cat:
                break

    if parent_cat:
        # Get child categories
        children = (
            db.query(Category)
            .filter(Category.parent_id == parent_cat.id, Category.is_active == True)
            .all()
        )
        if children:
            sub_categories = children

    # If DB has sub-categories, show them
    if sub_categories:
        rows = []
        for sc in sub_categories[:10]:
            rows.append({
                "id": f"subcat_{sc.id}",
                "title": f"{cat_def['emoji']} {sc.name[:20]}",
                "description": sc.description[:70] if sc.description else f"{cat_def['name']} — {sc.name}",
            })

        send_list(
            to,
            header=f"{cat_def['emoji']} {cat_def['name']}",
            body=t("category_header", emoji=cat_def["emoji"], catalog=cat_def["name"]),
            button_label="Select Type",
            sections=[{"title": f"{cat_def['name']} Types", "rows": rows}],
        )
        session["state"] = "catalog_selected"
    else:
        # No sub-categories (or we should check products) — go to product listing
        handle_catalog_products(to, session, db, catalog_id)


# ──────────────── STEP 6: PRODUCT LISTING (Level 3) ────────────────

def handle_category_products(to: str, session: dict, db: Session, category_id: int):
    """Show products under a specific DB sub-category."""
    session["browse_category_id"] = category_id
    category = db.query(Category).filter(Category.id == category_id).first()
    cat_name = category.name if category else "Products"
    catalog_id = session.get("browse_catalog", "general")
    cat_def = _get_catalog_def(catalog_id)

    products = (
        db.query(models.Product)
        .filter(models.Product.category_id == category_id, models.Product.is_active == True)
        .all()
    )

    if not products:
        send_text(to, t("no_products"))
        handle_show_catalogs(to, session, db)
        return

    rows = []
    for p in products[:10]:
        price = float(p.wholesale_price or p.price or 0)
        box_price = price * WEIGHT_PER_BOX
        if 1.2 <= price <= 1.3: box_price = 50.0 # Force ₹50.00 for Stripe minimum
        rows.append({
            "id": f"add_{p.id}",
            "title": f"{cat_def['emoji']} {p.name[:18]}",
            "description": f"1 Box (40 lbs) · ₹{box_price:.2f}",
        })

    send_list(
        to,
        header=f"{cat_def['emoji']} {cat_name}",
        body=t("product_list_header", emoji=cat_def["emoji"], category=cat_name),
        button_label="View Products",
        sections=[{"title": f"{cat_name}", "rows": rows}],
        footer="Tap a product to add to cart"
    )
    session["state"] = "category_products"


def handle_catalog_products(to: str, session: dict, db: Session, catalog_id: str):
    """Show products matching a catalog keyword or category ID (with sub-category fallback)."""
    logger.info(f"[CATALOG SEARCH] Requested ID: '{catalog_id}'")
    catalog_defs = session.get("_catalog_defs") or get_catalog_defs_from_db(db)
    cat_def = _get_catalog_def(catalog_id, catalog_defs)
    logger.info(f"[CATALOG SEARCH] Resolved Def: {cat_def}")
    session["browse_catalog"] = catalog_id
    
    products = []
    db_id = cat_def.get("db_id")
    logger.info(f"[CATALOG SEARCH] DB ID: {db_id}")

    # 1. Try by DB ID first (fetch products in this category AND all its sub-categories)
    if db_id:
        # Get all sub-category IDs
        sub_cat_ids = [db_id]
        children = db.query(Category.id).filter(Category.parent_id == db_id, Category.is_active == True).all()
        sub_cat_ids.extend([c[0] for c in children])
        
        products = (
            db.query(models.Product)
            .filter(models.Product.category_id.in_(sub_cat_ids), models.Product.is_active == True)
            .all()
        )

    # 2. Fallback to keyword search in product names
    if not products:
        keywords = list(cat_def.get("keywords", []))
        # Ensure name itself is included
        keywords.append(cat_def["name"].lower())
        
        # Add synonyms if not already there (redundant if get_catalog_defs_from_db did its job, but safe)
        kw_set = set(k.lower() for k in keywords)
        if any(k in kw_set for k in ["mutton", "goat", "lamb"]):
            kw_set.update(["mutton", "goat", "lamb", "sheep"])
        if any(k in kw_set for k in ["chicken", "bird"]):
            kw_set.update(["chicken", "bird", "poultry"])
        
        # Search products by keywords
        conditions = [models.Product.name.ilike(f"%{kw}%") for kw in kw_set]
        products = (
            db.query(models.Product)
            .filter(or_(*conditions), models.Product.is_active == True)
            .all()
        )

    # De-duplicate
    seen_ids = set()
    unique_products = []
    for p in products:
        if p.id not in seen_ids:
            seen_ids.add(p.id)
            unique_products.append(p)
    products = unique_products

    if not products:
        send_text(to, t("no_products"))
        handle_show_catalogs(to, session, db)
        return

    rows = []
    for p in products[:10]:
        price = float(p.wholesale_price or p.price or 0)
        box_price = price * WEIGHT_PER_BOX
        if 1.2 <= price <= 1.3: box_price = 50.0 # Force ₹50.00 for Stripe minimum
        rows.append({
            "id": f"add_{p.id}",
            "title": f"{cat_def['emoji']} {p.name[:18]}",
            "description": f"1 Box (40 lbs) · ₹{box_price:.2f}",
        })

    send_list(
        to,
        header=f"{cat_def['emoji']} {cat_def['name']}",
        body=t("product_list_header", emoji=cat_def["emoji"], category=cat_def["name"]),
        button_label="View Products",
        sections=[{"title": cat_def["name"], "rows": rows}],
        footer="Tap a product to add to cart"
    )
    session["state"] = "category_products"


# ──────────────── STEP 7-8: ADD TO CART & "ADD MORE" ────────────────

def handle_add_to_cart(to: str, session: dict, db: Session, product_id: str, boxes: float = 1):
    """Add product to cart and show 'Add More?' options."""
    product = db.query(models.Product).filter(models.Product.id == int(product_id)).first()
    if not product:
        send_text(to, "❌ Product not found.")
        return

    price = float(product.wholesale_price or product.price or 0)
    emoji = _get_product_emoji(product.name)

    # Check if already in cart — increment
    item = next((i for i in session["cart"] if i["id"] == str(product_id)), None)

    if item:
        item["qty"] += boxes
        if item["qty"] <= 0:
            session["cart"].remove(item)
            send_text(to, f"❌ {product.name} removed from cart.")
            _send_add_more_options(to, session)
            return
        item["weight"] = item["qty"] * WEIGHT_PER_BOX
        item["total"] = item["qty"] * WEIGHT_PER_BOX * price
    else:
        item = {
            "id": str(product_id),
            "name": product.name,
            "qty": boxes,
            "price_per_lb": price,
            "weight": boxes * WEIGHT_PER_BOX,
            "total": boxes * WEIGHT_PER_BOX * price,
        }
        session["cart"].append(item)

    # Show added confirmation + cart summary + "Add More?" options
    cart_text = _build_cart_summary(session["cart"])

    send_text(to, t("added_to_cart",
        emoji=emoji,
        name=product.name,
        qty=int(item["qty"]),
        weight=int(item["weight"]),
        total=item["total"],
        cart_summary=cart_text,
    ))

    _send_add_more_options(to, session)
    session["state"] = "add_more"


def _send_add_more_options(to: str, session: dict):
    """Show the 3 'Add More' options."""
    catalog_id = session.get("browse_catalog")
    cat_def = _get_catalog_def(catalog_id) if catalog_id else None

    buttons = []
    if session.get("browse_category_id"):
        buttons.append({"id": "addmore_same_cat", "title": "📋 Same Category"})
    if catalog_id:
        buttons.append({"id": "addmore_diff_cat", "title": "📂 Diff Category"})
    buttons.append({"id": "addmore_diff_catalog", "title": "🛒 Diff Catalog"})

    # Max 3 buttons
    buttons = buttons[:3]

    # Prioritize "View Cart"
    buttons.insert(0, {"id": "menu_cart", "title": "🛒 View Cart"})
    
    # Max 3 buttons
    buttons = buttons[:3]

    send_buttons(
        to,
        "Would you like to add more products?",
        buttons,
        footer="Or type 'cart' to view your cart"
    )


def handle_qty_change(to: str, session: dict, db: Session, product_id: str, delta: float):
    """Increment or decrement quantity for a product already in cart."""
    item = next((i for i in session["cart"] if i["id"] == str(product_id)), None)
    if not item:
        handle_add_to_cart(to, session, db, product_id, delta)
        return

    item["qty"] += delta
    if item["qty"] <= 0:
        session["cart"].remove(item)
        send_text(to, f"❌ *{item['name']}* removed from cart.")
        if session["cart"]:
            handle_view_cart(to, session)
        else:
            handle_show_catalogs(to, session, db)
        return

    item["weight"] = item["qty"] * WEIGHT_PER_BOX
    item["total"] = item["qty"] * WEIGHT_PER_BOX * item["price_per_lb"]

    send_buttons(
        to,
        t("qty_control", name=item["name"], qty=int(item["qty"]), weight=int(item["weight"]), total=item["total"]),
        [
            {"id": f"dec_{product_id}", "title": "➖ Remove 1"},
            {"id": f"inc_{product_id}", "title": "➕ Add 1"},
            {"id": "menu_cart", "title": "🛒 View Cart"},
        ]
    )
    session["state"] = "qty_control"


# ──────────────── STEP 9-10: CART VIEW & CHECKOUT ────────────────

def handle_view_cart(to: str, session: dict):
    """Show full cart with totals and checkout option."""
    cart = session["cart"]
    store = session.get("store", STORES[0])

    if not cart:
        send_buttons(
            to,
            t("cart_empty"),
            [{"id": "menu_catalog", "title": "🛒 Browse Products"}],
        )
        return

    # Build items text
    items_text = ""
    for i in cart:
        emoji = _get_product_emoji(i["name"])
        items_text += f"\n{emoji} *{i['name']}*\n   {int(i['qty'])} box(es) · {int(i['weight'])} lbs · ₹{i['total']:.2f}\n"

    totals = _calc_cart_totals(cart)
    session["checkout"] = totals

    body = (
        t("cart_header", store=store)
        + items_text
        + t("cart_footer", **totals)
    )

    send_buttons(
        to,
        body,
        [
            {"id": "cart_checkout", "title": "🚢 Checkout"},
            {"id": "cart_add_more", "title": "➕ Add More"},
            {"id": "cart_clear", "title": "❌ Clear Cart"},
        ],
    )
    session["state"] = "cart_view"


def handle_edit_cart(to: str, session: dict):
    """Show individual items for editing."""
    cart = session["cart"]
    if not cart:
        handle_view_cart(to, session)
        return

    send_text(to, "✏️ *Edit Cart Items:*\nUse ➕/➖ to adjust quantities:")

    for i in cart:
        emoji = _get_product_emoji(i["name"])
        body = f"{emoji} *{i['name']}*\n📦 {int(i['qty'])} box(es) · {int(i['weight'])} lbs · ₹{i['total']:.2f}"
        send_buttons(
            to,
            body,
            [
                {"id": f"dec_{i['id']}", "title": "➖ Remove 1"},
                {"id": f"inc_{i['id']}", "title": "➕ Add 1"},
                {"id": f"rem_{i['id']}", "title": "❌ Remove"},
            ],
        )

    send_buttons(
        to,
        "━━━━━━━━━━━━━━━━━━━━━━━━━",
        [{"id": "menu_cart", "title": "🔙 Back to Cart"}],
    )


# ──────────────── STEP 10-11: CHECKOUT → PICKUP DATE ────────────────

def handle_checkout_start(to: str, session: dict, db: Session):
    """Start checkout — skip name prompt if customer exists."""
    customer = db.query(models.Customer).filter(models.Customer.phone == to).first()
    if customer and customer.name:
        session["checkout"]["name"] = customer.name
        handle_checkout_name(to, session, customer.name)
    else:
        send_text(to, "👤 *Quick Checkout*\n\nPlease enter your *Full Name*:")
        session["state"] = "checkout_name"


def handle_checkout_name(to: str, session: dict, name: str):
    """Capture name, then show pickup date selection (store pickup only)."""
    session["checkout"]["name"] = name
    store = session.get("store", STORES[0])

    # Date selection (Today, Tomorrow, next 3 days)
    dates = _generate_pickup_dates()

    send_list(
        to,
        header="📅 Pickup Date",
        body=t("pickup_only"),
        button_label="Select Date",
        sections=[{"title": f"🏪 {store}", "rows": dates}],
        footer="Store Pickup Only"
    )
    session["state"] = "awaiting_pickup_date"


def handle_pickup_date(to: str, session: dict, date_index: int, date_title: str):
    """Pickup date selected — proceed to payment."""
    today = datetime.now()
    pickup_date = today + timedelta(days=date_index)
    session["checkout"]["pickup_date"] = pickup_date.strftime("%B %d, %Y")
    session["checkout"]["pickup_date_short"] = date_title
    session["checkout"]["delivery_type"] = "pickup"

    handle_payment_selection(to, session)


# ──────────────── STEP 12: PAYMENT SELECTION ────────────────

def handle_payment_selection(to: str, session: dict):
    """Show payment method options."""
    send_list(
        to,
        header="💳 Payment Method",
        body=t("payment_header"),
        button_label="Choose Payment",
        sections=[{
            "title": "Payment Options",
            "rows": [
                {"id": "pay_cod",    "title": "💵 Cash on Delivery", "description": "Pay when you pick up"},
                {"id": "pay_credit", "title": "💳 Stripe",          "description": "Pay securely with card"},
                {"id": "pay_debit",  "title": "💳 Debit Card",      "description": "Pay with debit card"},
                {"id": "pay_store",  "title": "🏪 Pay at Store",    "description": "Pay at the pickup point"},
                {"id": "pay_next",   "title": "📦 Next Delivery",   "description": "Bill on your next order"},
            ],
        }],
        footer="All payments are secure 🔒"
    )
    session["state"] = "await_payment_method"


# ──────────────── STEP 13: ORDER CONFIRMATION & INVOICE ────────────────

def _create_db_order(to: str, session: dict, db: Session, payment_method: str) -> int:
    """Create the order in the database. Returns the order ID."""
    cart = session.get("cart", [])
    checkout = session.get("checkout", {})
    store = session.get("store", "Dallas, TX")

    # Get or create customer
    customer = db.query(models.Customer).filter(models.Customer.phone == to).first()
    if not customer:
        customer = models.Customer(
            name=checkout.get("name", "WhatsApp User"),
            phone=to,
            customer_type="retail",
            status="active",
            preferred_location=store,
        )
        db.add(customer)
        db.flush()

    # Calculate total
    totals = _calc_cart_totals(cart)

    # Parse pickup date
    pickup_dt = None
    try:
        pickup_str = checkout.get("pickup_date")
        if pickup_str:
            pickup_dt = datetime.strptime(pickup_str, "%B %d, %Y")
    except Exception:
        pass

    # Create order
    new_order = models.Order(
        customer_id=customer.id,
        total_amount=totals["total"],
        status="confirmed",
        order_source="whatsapp",
        payment_status="pending" if payment_method != "Credit Card" else "paid",
        delivery_type="pickup",
        pickup_time=pickup_dt,
        notes=f"Store: {store} | Via: WhatsApp | Contact: {checkout.get('name', 'N/A')} | Payment: {payment_method}",
    )
    db.add(new_order)
    db.flush()

    # Create order items
    for item in cart:
        try:
            pid = int(item["id"])
            order_item = models.OrderItem(
                order_id=new_order.id,
                product_id=pid,
                quantity=int(item["qty"]),
                unit_price=item["price_per_lb"],
                total_price=item["total"],
            )
            db.add(order_item)

            # Reduce stock
            product = db.query(models.Product).filter(models.Product.id == pid).first()
            if product and product.stock_quantity:
                product.stock_quantity = max(0, product.stock_quantity - int(item["qty"]))
                db.add(product)
        except (ValueError, TypeError):
            pass

    db.commit()
    return new_order.id


def handle_order_confirmed(to: str, session: dict, db: Session, payment_method: str):
    """Finalize order: create in DB, send confirmation, PDF, thank you."""
    try:
        real_id = _create_db_order(to, session, db, payment_method)
        order_id_str = f"M2R-{real_id}"
        
        # If it's a "paid" method (like Credit Card should be after webhook), 
        # but here we handle the immediate ones (COD, etc.)
        finalize_and_notify_order(to, session, db, real_id, payment_method)
        
    except Exception as e:
        logger.error(f"[WA DB ERROR] {e}")
        send_text(to, t("error_generic"))


def handle_stripe_payment(to: str, session: dict, db: Session):
    """Create pending order and send Stripe Checkout link."""
    cart = session.get("cart", [])
    if not cart:
        send_text(to, "🛒 Your cart is empty.")
        return

    try:
        # 1. Create order in DB with pending status
        real_id = _create_db_order(to, session, db, "Credit Card")
        order = db.query(models.Order).filter(models.Order.id == real_id).first()
        order.payment_status = "pending"
        db.add(order)
        db.commit()

        # 2. Generate Stripe Checkout Session
        totals = _calc_cart_totals(cart)
        amount_cents = int(totals["total"] * 100)
        
        base_url = _get_public_base_url()
        
        metadata = {
            "order_id": str(real_id),
            "customer_phone": to,
            "source": "whatsapp"
        }
        
        stripe_session = stripe_utils.create_checkout_session(
            amount=amount_cents,
            currency="inr",
            metadata=metadata,
            success_url=f"{base_url}{settings.API_V1_STR}/stripe/payment-success?order_id={real_id}",
            cancel_url=f"{base_url}{settings.API_V1_STR}/stripe/payment-cancelled?order_id={real_id}"
        )

        # 3. Send link to user
        msg = (
            f"💳 *Complete Your Payment*\n"
            f"━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            f"Order: *M2R-{real_id}*\n"
            f"Total: *₹{totals['total']:.2f}*\n\n"
            f"Please tap the link below to pay securely via Stripe:\n\n"
            f"{stripe_session.url}\n\n"
            f"⏰ This link will expire soon."
        )
        send_text(to, msg)
        
        # 4. Do NOT clear session yet, wait for webhook
        # Or clear but keep enough to not break state? 
        # Actually, we should probably clear session so they don't buy twice,
        # but the webhook will handle the rest.
        remembered_store = session["store"]
        clear_session(to)
        new_session = get_session(to)
        new_session["store"] = remembered_store
        save_session(to, new_session)

    except Exception as e:
        logger.error(f"[STRIPE WA ERROR] {e}")
        send_text(to, f"⚠️ Failed to generate payment link: {str(e)}")


def finalize_and_notify_order(to: str, session: dict, db: Session, order_id: int, payment_method: str):
    """Shared logic to send invoice and final confirmation after payment/COD."""
    order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if not order:
        logger.error(f"Order {order_id} not found for finalization")
        return

    order_id_str = f"M2R-{order_id}"
    store = order.notes.split("|")[0].replace("Store: ", "").strip() if order.notes else "Store"
    
    # We might need to rebuild totals if session is gone (e.g. from webhook)
    customer_name = order.customer.name if order.customer else "Customer"
    total_amount = float(order.total_amount)

    # 1. Send confirmation message
    send_text(to, t("order_confirmed",
        order_id=order_id_str,
        store=store,
        pickup_date=order.pickup_time.strftime("%B %d, %Y") if order.pickup_time else "TBD",
        name=customer_name,
        payment=payment_method,
        total=total_amount,
    ))

    # 2. Send items summary
    items_lines = []
    for item in order.items:
        emoji = _get_product_emoji(item.product.name)
        items_lines.append(f"{emoji} {item.product.name} — {int(item.quantity)} box(es) — ₹{item.total_price:.2f}")
    send_text(to, "📋 *Order Items:*\n" + "\n".join(items_lines))

    # 3. Generate & send PDF invoice
    try:
        # Re-calc subtotal and tax for PDF
        tax_rate = 0.0825
        subtotal = total_amount / (1 + tax_rate)
        tax = total_amount - subtotal

        pdf_path = pdf_generator.generate_invoice({
            "order_id": order_id_str,
            "date": datetime.now().strftime("%Y-%m-%d"),
            "customer_name": customer_name,
            "customer_phone": to,
            "store": store,
            "items": [
                {
                    "name": item.product.name,
                    "qty": f"{int(item.quantity)} box(es)",
                    "price": f"₹{item.total_price:.2f}",
                }
                for item in order.items
            ],
            "subtotal": f"₹{subtotal:.2f}",
            "tax": f"₹{tax:.2f}",
            "total": f"₹{total_amount:.2f}",
            "payment_method": payment_method,
        })

        media_id = whatsapp_service.upload_media(pdf_path)
        if media_id:
            whatsapp_service.send_document(to, media_id, f"Invoice_{order_id_str}.pdf")
    except Exception as e:
        logger.error(f"[PDF ERROR] {e}")

    # 4. Thank you message
    send_text(to, t("thank_you"))


# ──────────────── MY ORDERS ────────────────

def handle_my_orders(to: str, session: dict, db: Session):
    """Show recent orders for the customer."""
    try:
        customer = db.query(models.Customer).filter(models.Customer.phone == to).first()
        if customer:
            orders = (
                db.query(models.Order)
                .filter(models.Order.customer_id == customer.id)
                .order_by(models.Order.id.desc())
                .limit(5)
                .all()
            )
            if orders:
                lines = ["📦 *Your Recent Orders:*\n━━━━━━━━━━━━━━━━━━━━━━━━━"]
                for o in orders:
                    status_emoji = {"confirmed": "✅", "pending": "⏳", "packed": "📦", "delivered": "🚚", "cancelled": "❌"}.get(o.status, "📋")
                    lines.append(f"{status_emoji} Order #{o.id} — {o.status.title()} — ₹{o.total_amount:.2f}")
                send_text(to, "\n".join(lines))
                handle_show_catalogs(to, session, db)
                return
    except Exception as e:
        logger.error(f"[Orders] {e}")

    send_text(to, "📦 No recent orders found.\n\nStart shopping to place your first order!")
    handle_show_catalogs(to, session, db)


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN MESSAGE PROCESSOR
# ═══════════════════════════════════════════════════════════════════════════════

def process_message(to: str, msg_type: str, body: str, button_id: str, db: Session):
    session = get_session(to)
    state = session.get("state", "welcome")

    logger.info(f"[BOT] {to} | state={state} | body={body!r} | btn={button_id!r}")

    # ─── Global Commands (text) ───
    body_upper = body.strip().upper()
    if any(w == body_upper for w in ["HI", "HELLO", "HEY", "START", "MENU"]):
        clear_session(to)
        session = get_session(to)
        handle_welcome(to, session, db)
        save_session(to, session)
        return

    if body_upper == "CART":
        handle_view_cart(to, session)
        save_session(to, session)
        return

    # ─── Interactive Button/List Replies ───
    if button_id:
        bid = button_id

        # Store selection
        if bid.startswith("store_"):
            idx = int(bid.replace("store_", ""))
            handle_store_selected(to, session, db, idx)
            save_session(to, session)
            return

        # Reorder confirm
        if bid == "reorder_confirm":
            reorder_items = session.pop("_reorder_items", None)
            if reorder_items:
                session["cart"] = reorder_items
            handle_view_cart(to, session)
            save_session(to, session)
            return

        # Catalog selected (Level 1)
        if bid.startswith("catalog_"):
            catalog_id = bid.replace("catalog_", "")
            handle_catalog_selected(to, session, db, catalog_id)
            save_session(to, session)
            return

        # Sub-category selected (Level 2)
        if bid.startswith("subcat_"):
            cat_id = int(bid.replace("subcat_", ""))
            handle_category_products(to, session, db, cat_id)
            save_session(to, session)
            return

        # Add to cart from product list
        if bid.startswith("add_"):
            pid = bid.replace("add_", "")
            handle_add_to_cart(to, session, db, pid)
            save_session(to, session)
            return

        # Quantity controls
        if bid.startswith("inc_"):
            pid = bid.replace("inc_", "")
            handle_qty_change(to, session, db, pid, 1)
            save_session(to, session)
            return
        if bid.startswith("dec_"):
            pid = bid.replace("dec_", "")
            handle_qty_change(to, session, db, pid, -1)
            save_session(to, session)
            return
        if bid.startswith("rem_"):
            pid = bid.replace("rem_", "")
            item = next((i for i in session["cart"] if i["id"] == pid), None)
            if item:
                session["cart"].remove(item)
                send_text(to, f"❌ *{item['name']}* removed from cart.")
            handle_view_cart(to, session)
            save_session(to, session)
            return

        # "Add More" options
        if bid == "addmore_same_cat":
            cat_id = session.get("browse_category_id")
            if cat_id:
                handle_category_products(to, session, db, cat_id)
            else:
                catalog_id = session.get("browse_catalog")
                if catalog_id:
                    handle_catalog_products(to, session, db, catalog_id)
                else:
                    handle_show_catalogs(to, session, db)
            save_session(to, session)
            return

        if bid == "addmore_diff_cat":
            catalog_id = session.get("browse_catalog")
            if catalog_id:
                handle_catalog_selected(to, session, db, catalog_id)
            else:
                handle_show_catalogs(to, session, db)
            save_session(to, session)
            return

        if bid in ("addmore_diff_catalog", "menu_catalog"):
            handle_show_catalogs(to, session, db)
            save_session(to, session)
            return

        # Cart actions
        if bid == "menu_cart" or bid == "cart_add_more":
            if bid == "cart_add_more":
                handle_show_catalogs(to, session, db)
            else:
                handle_view_cart(to, session)
            save_session(to, session)
            return

        if bid == "cart_checkout":
            handle_checkout_start(to, session, db)
            save_session(to, session)
            return

        if bid == "cart_edit":
            handle_edit_cart(to, session)
            save_session(to, session)
            return

        if bid == "cart_clear":
            session["cart"] = []
            send_text(to, t("order_cancelled"))
            handle_show_catalogs(to, session, db)
            save_session(to, session)
            return

        # Pickup date selection
        if bid.startswith("date_"):
            idx = int(bid.replace("date_", ""))
            handle_pickup_date(to, session, idx, body)
            save_session(to, session)
            return

        # Payment method selection
        if bid.startswith("pay_"):
            methods = {
                "pay_cod": "Cash on Delivery",
                "pay_credit": "Credit Card",
                "pay_debit": "Debit Card",
                "pay_store": "Pay at Store",
                "pay_next": "Pay on Next Delivery",
            }
            method = methods.get(bid, "Other")
            if bid == "pay_credit":
                handle_stripe_payment(to, session, db)
            else:
                handle_order_confirmed(to, session, db, method)
            save_session(to, session)
            return

        # My Orders
        if bid == "menu_orders":
            handle_my_orders(to, session, db)
            save_session(to, session)
            return

    # ─── Text Input (State-based) ───
    if state == "checkout_name":
        handle_checkout_name(to, session, body.strip())
        save_session(to, session)
        return

    if state == "qty_custom":
        try:
            qty = float(body.strip())
            if qty > 0:
                pid = session.get("pending_item")
                if pid:
                    handle_add_to_cart(to, session, db, pid, qty)
                else:
                    send_text(to, "❌ No product selected. Please browse products first.")
                    handle_show_catalogs(to, session, db)
            else:
                send_text(to, "❌ Please enter a number greater than 0.")
        except ValueError:
            send_text(to, "❌ Please enter a valid number of boxes (e.g. *5*).")
        save_session(to, session)
        return

    # ─── Fallback ───
    if not session.get("store"):
        handle_welcome(to, session, db)
    else:
        handle_show_catalogs(to, session, db)
    save_session(to, session)


# ═══════════════════════════════════════════════════════════════════════════════
# WEBHOOK ENDPOINTS
# ═══════════════════════════════════════════════════════════════════════════════

@router.get("/webhook")
def verify_webhook(
    hub_mode: str = Query(None, alias="hub.mode"),
    hub_verify_token: str = Query(None, alias="hub.verify_token"),
    hub_challenge: str = Query(None, alias="hub.challenge"),
):
    if hub_mode == "subscribe" and hub_verify_token == settings.WHATSAPP_VERIFY_TOKEN:
        return PlainTextResponse(content=hub_challenge)
    raise HTTPException(status_code=403, detail="Verification failed")


@router.post("/order-ready/{order_id}")
async def notify_order_ready(order_id: int, db: Session = Depends(deps.get_db)):
    """Triggered by Admin Panel to notify customer order is ready."""
    order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if not order or not order.customer:
        raise HTTPException(status_code=404, detail="Order or Customer not found")

    to = order.customer.phone
    msg = (
        f"✅ *Good news!* Your order *#{order_id}* is freshly packed "
        f"and ready for pickup at *Meat2Restaurant*.\n\n"
        f"📍 Store: *{order.notes or 'Store'}*\n"
        f"📦 Ready for: *{order.customer.name}*\n\n"
        f"_See you soon!_ 🥩"
    )
    send_text(to, msg)
    send_buttons(
        to,
        "Need help finding us?",
        [
            {"id": "get_directions", "title": "📍 Get Directions"},
            {"id": "contact_store", "title": "📞 Call Store"},
        ],
    )

    order.reminder_ready_sent = True
    db.add(order)
    db.commit()
    return {"status": "success", "message": "Notification sent"}


@router.post("/webhook")
async def whatsapp_webhook(request: Request, db: Session = Depends(deps.get_db)):
    try:
        data = await request.json()

        for entry in data.get("entry", []):
            for change in entry.get("changes", []):
                value = change.get("value", {})

                for message in value.get("messages", []):
                    from_number = message.get("from")
                    msg_type = message.get("type")
                    body = ""
                    button_id = ""

                    if msg_type == "text":
                        body = message.get("text", {}).get("body", "")

                    elif msg_type == "interactive":
                        interactive = message.get("interactive", {})
                        itype = interactive.get("type")
                        if itype == "button_reply":
                            button_id = interactive.get("button_reply", {}).get("id", "")
                            body = interactive.get("button_reply", {}).get("title", "")
                        elif itype == "list_reply":
                            button_id = interactive.get("list_reply", {}).get("id", "")
                            body = interactive.get("list_reply", {}).get("title", "")

                    if from_number and (body or button_id):
                        process_message(from_number, msg_type, body, button_id, db)

        return {"status": "ok"}
    except Exception as e:
        logger.error(f"[WEBHOOK ERROR] {e}")
        traceback.print_exc()
        return {"status": "ok"}
