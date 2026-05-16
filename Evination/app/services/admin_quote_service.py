from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.vendor_bid_m import VendorBid
from app.models.event_m import Event
from app.models.vendor_m import Vendor
from app.models.user_m import User
from app.schemas.admin_quote_schema import (
    AdminQuoteDetailSchema,
    QuoteVendorSchema,
    QuoteItemSchema,
    QuoteListSchema,
    QuoteComparisonResponseSchema
)
from datetime import timedelta
from typing import List

class AdminQuoteService:

    @staticmethod
    def get_quote_details(db: Session, quote_id: str):
        # 1. Parse ID (Frontend sends "QT-{id}", or just ID. We handle robustly)
        # Assuming frontend might send "QT-10" or just "10"
        bid_id_str = quote_id.replace("QT-", "")
        if not bid_id_str.isdigit():
             raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid Quote ID format"
            )
        
        bid_id = int(bid_id_str)

        # 2. Fetch Bid with relations
        bid = db.query(VendorBid).filter(VendorBid.id == bid_id).first()
        
        if not bid:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Quote (Bid) not found"
            )

        # 3. Transform Data
        
        # Vendor Helper
        vendor = bid.vendor
        vendor_user = db.query(User).filter(User.id == vendor.user_id).first()
        vendor_email = vendor_user.email if vendor_user else "N/A"
        contact_name = f"{vendor_user.first_name or ''} {vendor_user.last_name or ''}".strip() if vendor_user else vendor.company_name

        vendor_schema = QuoteVendorSchema(
            name=vendor.company_name,
            contact=contact_name,
            email=vendor_email,
            phone=vendor.phone or "N/A"
        )

        # Items Helper
        # VendorBid stores items in `service_breakdown` (JSON)
        # Expected format in JSON: [{"service_name": "...", "cost": 1000, "notes": "..."}]
        # QuoteItemSchema needs: id, description, quantity, unitPrice, total
        
        quote_items = []
        raw_items = bid.service_breakdown or []
        
        subtotal = 0.0
        
        # If raw_items is not a list (e.g. None or malformed), handle gracefully
        if isinstance(raw_items, list):
            for idx, item in enumerate(raw_items):
                # We mock quantity as 1 if not present, because our current JSON structure didn't enforce it strictly
                # But typically for a bid, it's a lump sum per service or itemized.
                # We'll assume cost is the total for that line item.
                
                desc = item.get("service_name", "Service")
                notes = item.get("notes", "")
                if notes:
                    desc += f" ({notes})"
                
                cost = float(item.get("cost", 0))
                qty = 1 # Simple default
                unit_price = cost # Simple default
                
                quote_items.append(QuoteItemSchema(
                    id=idx + 1,
                    description=desc,
                    quantity=qty,
                    unitPrice=unit_price,
                    total=cost
                ))
                subtotal += cost
        
        # Financials
        # Only total_amount is strictly stored.
        # We derived subtotal from items.
        # We can 'back-calculate' validation or just trust the items sum vs bid.total_amount
        # For display, let's trust the items sum as subtotal.
        
        # MOCK LOGIC for fields missing in backend:
        # Tax = 10% (hardcoded example as per frontend design)
        # Discount = 0 (hardcoded)
        # ValidUntil = Submitted + 30 days
        
        tax_rate = 0.10
        tax = subtotal * tax_rate
        discount = 0.0
        
        # To match the bid.total_amount (which is final), we might need to adjust.
        # However, usually Bid.total_amount IS the final price.
        # So let's reverse calculate checks or just display calculated values.
        # Ideally: final_total = subtotal + tax - discount
        final_total = subtotal + tax - discount
        
        # Dates
        submitted_at = bid.submitted_at or bid.created_at
        valid_until_dt = submitted_at + timedelta(days=30)
        valid_until_str = valid_until_dt.strftime("%b %d, %Y")
        event_date_str = bid.event.event_date.strftime("%b %d, %Y")

        # Terms
        # Using the text field and splitting by newline for list format
        terms_text = bid.terms_and_conditions or ""
        terms_list = [t.strip() for t in terms_text.split("\n") if t.strip()]
        
        # 4. Construct Response
        return AdminQuoteDetailSchema(
            id=f"QT-{bid.id}",
            orderId=f"ORD-{bid.event_id}", # Using Event ID as proxy for Order ID context
            eventName=bid.event.name,
            eventDate=event_date_str,
            location=bid.event.location or "TBD",
            vendor=vendor_schema,
            status=bid.status.title(), # e.g. "Draft"
            validUntil=valid_until_str,
            items=quote_items,
            subtotal=subtotal,
            tax=tax,
            discount=discount,
            total=final_total,
            terms=terms_list,
            notes=bid.proposal_description
        )

    @staticmethod
    def get_all_quotes(db: Session, skip: int = 0, limit: int = 100):
        bids = db.query(VendorBid).offset(skip).limit(limit).all()
        results = []
        for bid in bids:
            # Flatten/Transform for list view
            submitted_at = bid.submitted_at or bid.created_at
            submitted_str = submitted_at.strftime("%b %d, %Y")
            vendor_name = bid.vendor.company_name
            
            results.append(QuoteListSchema(
                id=f"QT-{bid.id}",
                orderId=f"ORD-{bid.event_id}",
                eventName=bid.event.name,
                vendorName=vendor_name,
                totalAmount=float(bid.total_amount),
                status=bid.status.title(),
                submittedAt=submitted_str
            ))
        return results

    @staticmethod
    def compare_quotes(db: Session, quote_ids: List[str]):
        # Reuse get_quote_details logic for each ID
        # This is not the most efficient (N queries), but ensures consistency with detail view logic
        compared_quotes = []
        for q_id in quote_ids:
            try:
                details = AdminQuoteService.get_quote_details(db, q_id)
                compared_quotes.append(details)
            except HTTPException:
                # If one quote is invalid, we might skip it or fail. 
                # For now let's skip invalid IDs to be robust
                continue
        
        return QuoteComparisonResponseSchema(quotes=compared_quotes)
