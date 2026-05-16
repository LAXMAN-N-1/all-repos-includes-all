# app/services/admin_vendor_service.py

from sqlalchemy.orm import Session
from sqlalchemy import func
from fastapi import HTTPException
from typing import List, Optional
from datetime import datetime

from app.models.vendor_m import Vendor
from app.models.user_m import User
from app.models.service_m import Service
from app.models.vendor_notification_m import VendorNotification


class AdminVendorService:
    
    @staticmethod
    def get_pending_vendors(db: Session, skip: int = 0, limit: int = 100):
        """Get all pending vendor registrations"""
        vendors = db.query(Vendor).join(
            User, Vendor.user_id == User.id
        ).filter(
            Vendor.status == "pending",
            Vendor.inactive == False
        ).offset(skip).limit(limit).all()
        
        result = []
        for vendor in vendors:
            # Get user details
            user = db.query(User).filter(User.id == vendor.user_id).first()
            
            # Get service names
            services = []
            if vendor.offered_services:
                service_objs = db.query(Service).filter(
                    Service.id.in_(vendor.offered_services)
                ).all()
                services = [{"id": s.id, "name": s.name, "code": s.code} for s in service_objs]
            
            result.append({
                "id": vendor.id,
                "companyName": vendor.company_name,
                "businessType": vendor.business_type,
                "email": user.email if user else None,
                "phone": vendor.phone,
                "address": vendor.address,
                "city": vendor.city,
                "state": vendor.state,
                "zipCode": vendor.zip_code,
                "offeredServices": services,
                "serviceAreas": vendor.service_areas or [],
                "status": vendor.status,
                "registeredAt": vendor.created_at
            })
        
        return result
    
    @staticmethod
    def get_vendor_details(db: Session, vendor_id: int):
        """Get detailed vendor information"""
        vendor = db.query(Vendor).filter(
            Vendor.id == vendor_id,
            Vendor.inactive == False
        ).first()
        
        if not vendor:
            raise HTTPException(status_code=404, detail="Vendor not found")
        
        # Get user details
        user = db.query(User).filter(User.id == vendor.user_id).first()
        
        # Get service details
        services = []
        if vendor.offered_services:
            service_objs = db.query(Service).filter(
                Service.id.in_(vendor.offered_services)
            ).all()
            services = [
                {
                    "id": s.id,
                    "name": s.name,
                    "code": s.code,
                    "icon": s.icon
                } for s in service_objs
            ]
        
        # Get bid statistics
        from app.models.vendor_bid_m import VendorBid
        total_bids = db.query(func.count(VendorBid.id)).filter(
            VendorBid.vendor_id == vendor_id,
            VendorBid.inactive == False
        ).scalar() or 0
        
        won_bids = db.query(func.count(VendorBid.id)).filter(
            VendorBid.vendor_id == vendor_id,
            VendorBid.status == "won",
            VendorBid.inactive == False
        ).scalar() or 0
        
        return {
            "id": vendor.id,
            "userId": vendor.user_id,
            "companyName": vendor.company_name,
            "businessType": vendor.business_type,
            "email": user.email if user else None,
            "phone": vendor.phone,
            "address": vendor.address,
            "city": vendor.city,
            "state": vendor.state,
            "zipCode": vendor.zip_code,
            "offeredServices": services,
            "serviceAreas": vendor.service_areas or [],
            "status": vendor.status,
            "rating": float(vendor.rating) if vendor.rating else 0,
            "totalBids": total_bids,
            "wonBids": won_bids,
            "registeredAt": vendor.created_at,
            "approvedAt": vendor.updated_at if vendor.status == "approved" else None
        }
    
    @staticmethod
    def approve_vendor(db: Session, vendor_id: int, admin_user):
        """Approve a pending vendor"""
        vendor = db.query(Vendor).filter(
            Vendor.id == vendor_id,
            Vendor.inactive == False
        ).first()
        
        if not vendor:
            raise HTTPException(status_code=404, detail="Vendor not found")
        
        if vendor.status != "pending":
            raise HTTPException(
                status_code=400,
                detail=f"Vendor is already {vendor.status}"
            )
        
        # Update vendor status
        vendor.status = "approved"
        vendor.modified_by = admin_user.username
        
        # Send notification to vendor
        db.add(VendorNotification(
            vendor_id=vendor.id,
            notification_type="account_approved",
            title="🎉 Your Vendor Account is Approved!",
            message=(
                f"Congratulations! Your vendor account for {vendor.company_name} "
                "has been approved. You can now start bidding on events."
            ),
            priority="high",
            category="account",
            action_url="/vendor/dashboard",
            action_text="Go to Dashboard",
            created_by=admin_user.username
        ))
        
        db.commit()
        db.refresh(vendor)
        
        return {
            "message": "Vendor approved successfully",
            "vendorId": vendor.id,
            "status": vendor.status
        }
    
    @staticmethod
    def reject_vendor(db: Session, vendor_id: int, reason: str, admin_user):
        """Reject a pending vendor"""
        vendor = db.query(Vendor).filter(
            Vendor.id == vendor_id,
            Vendor.inactive == False
        ).first()
        
        if not vendor:
            raise HTTPException(status_code=404, detail="Vendor not found")
        
        if vendor.status != "pending":
            raise HTTPException(
                status_code=400,
                detail=f"Vendor is already {vendor.status}"
            )
        
        # Update vendor status
        vendor.status = "rejected"
        vendor.modified_by = admin_user.username
        
        # Send notification to vendor
        db.add(VendorNotification(
            vendor_id=vendor.id,
            notification_type="account_rejected",
            title="Vendor Account Application Update",
            message=(
                f"We regret to inform you that your vendor account application "
                f"for {vendor.company_name} has been declined.\n\n"
                f"Reason: {reason}\n\n"
                "You may contact support for more information."
            ),
            priority="high",
            category="account",
            action_url="/vendor/support",
            action_text="Contact Support",
            created_by=admin_user.username
        ))
        
        db.commit()
        db.refresh(vendor)
        
        return {
            "message": "Vendor rejected",
            "vendorId": vendor.id,
            "status": vendor.status
        }
