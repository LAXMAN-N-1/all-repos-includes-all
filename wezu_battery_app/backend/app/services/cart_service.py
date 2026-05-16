from __future__ import annotations
from fastapi import HTTPException
from sqlalchemy.exc import SQLAlchemyError
from sqlmodel import Session, select
from app.models.cart import CartItem
from app.models.catalog import CatalogProduct, CatalogProductVariant
from typing import List, Optional
from datetime import datetime, timezone; UTC = timezone.utc

class CartService:
    @staticmethod
    def _is_missing_schema_error(exc: Exception) -> bool:
        message = str(getattr(exc, "orig", exc)).lower()
        return (
            "does not exist" in message
            or "undefinedtable" in message
            or "undefinedcolumn" in message
        )

    @staticmethod
    def _schema_unavailable() -> HTTPException:
        return HTTPException(
            status_code=503,
            detail="Cart service is temporarily unavailable. Please run pending migrations.",
        )

    @staticmethod
    def get_cart(db: Session, user_id: int) -> List[dict]:
        """Get all items in user's cart with product details"""
        statement = (
            select(CartItem, CatalogProduct)
            .join(CatalogProduct, CartItem.product_id == CatalogProduct.id)
            .where(CartItem.user_id == user_id)
        )
        try:
            results = db.exec(statement).all()
        except SQLAlchemyError as exc:
            if CartService._is_missing_schema_error(exc):
                db.rollback()
                return []
            raise
        
        cart_data = []
        for item, product in results:
            variant = None
            if item.variant_id:
                variant = db.get(CatalogProductVariant, item.variant_id)
                
            cart_data.append({
                "id": item.id,
                "product_id": item.product_id,
                "variant_id": item.variant_id,
                "quantity": item.quantity,
                "product": {
                    "id": product.id,
                    "name": product.name,
                    "price": product.price,
                    "image_url": product.images[0].image_url if product.images else None,
                    "brand": product.brand
                },
                "variant": {
                    "id": variant.id,
                    "name": variant.variant_name,
                    "price": variant.price or product.price
                } if variant else None
            })
        return cart_data

    @staticmethod
    def add_to_cart(db: Session, user_id: int, product_id: int, variant_id: Optional[int] = None, quantity: int = 1) -> CartItem:
        """Add item to cart or update quantity if exists"""
        statement = select(CartItem).where(
            CartItem.user_id == user_id,
            CartItem.product_id == product_id,
            CartItem.variant_id == variant_id
        )
        try:
            item = db.exec(statement).first()
        except SQLAlchemyError as exc:
            if CartService._is_missing_schema_error(exc):
                db.rollback()
                raise CartService._schema_unavailable()
            raise
        
        if item:
            item.quantity += quantity
            item.updated_at = datetime.now(UTC)
        else:
            item = CartItem(
                user_id=user_id,
                product_id=product_id,
                variant_id=variant_id,
                quantity=quantity
            )
            db.add(item)
            
        db.commit()
        db.refresh(item)
        return item

    @staticmethod
    def update_quantity(db: Session, user_id: int, item_id: int, quantity: int) -> Optional[CartItem]:
        """Update quantity of a specific cart item"""
        try:
            item = db.get(CartItem, item_id)
        except SQLAlchemyError as exc:
            if CartService._is_missing_schema_error(exc):
                db.rollback()
                raise CartService._schema_unavailable()
            raise
        if not item or item.user_id != user_id:
            return None
            
        if quantity <= 0:
            db.delete(item)
            db.commit()
            return None
            
        item.quantity = quantity
        item.updated_at = datetime.now(UTC)
        db.add(item)
        db.commit()
        db.refresh(item)
        return item

    @staticmethod
    def remove_from_cart(db: Session, user_id: int, item_id: int) -> bool:
        """Remove item from cart"""
        try:
            item = db.get(CartItem, item_id)
        except SQLAlchemyError as exc:
            if CartService._is_missing_schema_error(exc):
                db.rollback()
                raise CartService._schema_unavailable()
            raise
        if not item or item.user_id != user_id:
            return False
            
        db.delete(item)
        db.commit()
        return True

    @staticmethod
    def clear_cart(db: Session, user_id: int):
        """Clear entire cart for user"""
        statement = select(CartItem).where(CartItem.user_id == user_id)
        try:
            items = db.exec(statement).all()
        except SQLAlchemyError as exc:
            if CartService._is_missing_schema_error(exc):
                db.rollback()
                raise CartService._schema_unavailable()
            raise
        for item in items:
            db.delete(item)
        db.commit()
