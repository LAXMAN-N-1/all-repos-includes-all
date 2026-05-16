from __future__ import annotations
from typing import Optional, Any, TYPE_CHECKING
from sqlalchemy.orm import Session

if TYPE_CHECKING:
    from app import models

class PricingService:
    def calculate_unit_price(
        self, 
        db: Session, 
        product: models.Product, 
        customer: models.Customer, 
        quantity: int, 
        variant_id: Optional[int] = None
    ) -> float:
        """
        Calculate the best unit price for a given customer and product quantity.
        Priority:
        1. Contract Price (PartnerPrice)
        2. Volume Tier Discount (if B2B)
        3. Variant Override (Wholesale/Retail)
        4. Wholesale Price (if B2B)
        5. Standard Retail Price
        """
        from app import models
        
        # 0. Handle Variant Overrides
        variant = None
        if variant_id:
            variant = db.query(models.ProductVariant).filter(models.ProductVariant.id == variant_id).first()
        
        # 1. Check for Partner-Specific Contract Price
        contract_price = db.query(models.PartnerPrice).filter(
            models.PartnerPrice.partner_id == customer.id,
            models.PartnerPrice.product_id == product.id
        ).first()
        
        if contract_price:
            return contract_price.custom_price
            
        # Check B2B Logic (Wholesale & Tiers)
        if customer.customer_type == "b2b":
            # 2. Volume Tiers
            if product.volume_tiers:
                best_tier_price = None
                max_threshold = -1
                for threshold_str, tier_price in product.volume_tiers.items():
                    try:
                        threshold = int(threshold_str)
                        if quantity >= threshold and threshold > max_threshold:
                            max_threshold = threshold
                            best_tier_price = tier_price
                    except ValueError:
                        continue
                if best_tier_price is not None:
                    return best_tier_price

            # 3. Variant Wholesale Price Override
            if variant and variant.wholesale_price is not None:
                return variant.wholesale_price

            # 4. Wholesale Price
            if product.wholesale_price is not None:
                return product.wholesale_price

        # 5. Variant Retail Price Override
        if variant and variant.price is not None:
            return variant.price

        # 6. Fallback to Standard Retail Price
        return product.price

pricing_service = PricingService()
