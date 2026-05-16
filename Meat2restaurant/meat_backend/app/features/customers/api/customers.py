import datetime
import random
from datetime import timedelta
from typing import Any, List

from fastapi import APIRouter, Body, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import models, schemas
from app.api import deps
from app.core import security

router = APIRouter()


@router.get("/", response_model=List[schemas.Customer])
def read_customers(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    is_verified: bool = None,
    current_user: Any = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve customers.
    - Staff: See all.
    - Partner: See only self.
    """
    query = db.query(models.Customer)
    
    if getattr(current_user, "identity_type", None) == "partner":
        query = query.filter(models.Customer.id == current_user.id)
        customers = query.offset(skip).limit(limit).all()
    else:
        if is_verified is not None:
            query = query.filter(models.Customer.is_verified == is_verified)
            
        # Optimization: If email exists in both, make sure own profile is first
        all_customers = query.offset(skip).limit(limit).all()
        customers = []
        # Find self if exists in customer table
        self_customer = next((c for c in all_customers if c.email == getattr(current_user, "email", None)), None)
        if self_customer:
            customers.append(self_customer)
            customers.extend([c for c in all_customers if c.id != self_customer.id])
        else:
            customers = all_customers

    return customers


@router.post("/", response_model=schemas.Customer)
def create_customer(
    *,
    db: Session = Depends(deps.get_db),
    customer_in: schemas.CustomerCreate,
    current_user: Any = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Create new customer (Staff Only).
    """
    print(f"DEBUG: create_customer - payload: {customer_in.dict()}")
    customer = db.query(models.Customer).filter(models.Customer.email == customer_in.email).first()
    if customer:
        raise HTTPException(
            status_code=400,
            detail="The customer with this email already exists in the system.",
        )
    customer = models.Customer(
        name=customer_in.name,
        email=customer_in.email,
        phone=customer_in.phone,
        address=customer_in.address,
        zip_code=customer_in.zip_code,
        customer_type=customer_in.customer_type,
        billing_cycle=customer_in.billing_cycle,
        business_name=customer_in.business_name,
        tax_id=customer_in.tax_id,
        business_description=customer_in.business_description,
        hashed_password=security.get_password_hash(customer_in.password),
        credit_limit=customer_in.credit_limit,
        is_verified=customer_in.is_verified,
        status=customer_in.status,
        stripe_customer_id=customer_in.stripe_customer_id,
        current_balance=customer_in.current_balance,
        wallet_balance=customer_in.wallet_balance,
        wallet_enabled=customer_in.wallet_enabled,
        cycle_start_day=customer_in.cycle_start_day,
        cycle_cutoff_day=customer_in.cycle_cutoff_day,
        payment_due_day=customer_in.payment_due_day,
    )
    db.add(customer)
    db.commit()
    db.refresh(customer)
    return customer


# --- Membership Plans (Moved before user_id routes to avoid shadowing) ---
@router.post("/membership-plans", response_model=schemas.MembershipPlan)
def create_membership_plan(
    plan_in: schemas.MembershipPlanCreate,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_superuser),
):
    """
    Create a new membership plan (Admin only)
    """
    db_obj = models.MembershipPlan(
        name=plan_in.name, 
        description=plan_in.description,
        price=plan_in.price, 
        duration_days=plan_in.duration_days,
        benefits=plan_in.benefits,
        is_active=plan_in.is_active
    )
    db.add(db_obj)
    db.commit() 
    db.refresh(db_obj)
    return db_obj

@router.get("/membership-plans", response_model=List[schemas.MembershipPlan])
def read_membership_plans(db: Session = Depends(deps.get_db)):
    """
    Get all membership plans
    """
    return db.query(models.MembershipPlan).all()

@router.put("/membership-plans/{plan_id}", response_model=schemas.MembershipPlan)
def update_membership_plan(
    plan_id: int,
    plan_in: schemas.MembershipPlanUpdate,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_superuser),
):
    """
    Update a membership plan (Admin only)
    """
    db_obj = db.query(models.MembershipPlan).filter(models.MembershipPlan.id == plan_id).first()
    if not db_obj:
        raise HTTPException(status_code=404, detail="Membership plan not found")
    
    update_data = plan_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_obj, field, value)
    
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.delete("/membership-plans/{plan_id}", response_model=schemas.MembershipPlan)
def delete_membership_plan(
    plan_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_superuser),
):
    """
    Delete a membership plan (Admin only)
    """
    db_obj = db.query(models.MembershipPlan).filter(models.MembershipPlan.id == plan_id).first()
    if not db_obj:
        raise HTTPException(status_code=404, detail="Membership plan not found")
    
    db.delete(db_obj)
    db.commit()
    return db_obj


@router.get("/{customer_id}", response_model=schemas.Customer)
def read_customer(
    customer_id: int,
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get customer by ID.
    - Staff: Any.
    - Partner: Only self.
    """
    # Security: Partners only see themselves
    if getattr(current_user, "identity_type", None) == "partner":
        if current_user.id != customer_id:
            raise HTTPException(status_code=403, detail="Not authorized to view this profile")

    customer = db.query(models.Customer).filter(models.Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    return customer

@router.put("/{customer_id}", response_model=schemas.Customer)
def update_customer(
    *,
    db: Session = Depends(deps.get_db),
    customer_id: int,
    customer_in: Any = Body(...), # Use Any to handle multiple schema types via Body
    current_user: Any = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update a customer.
    - Staff: Full Control (Admin Schema).
    - Partner: Profile Only (Partner Schema).
    """
    customer = db.query(models.Customer).filter(models.Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    is_partner = getattr(current_user, "identity_type", None) == "partner"
    print(f"DEBUG: update_customer - ID: {customer_id}, is_partner: {is_partner}, is_superuser: {getattr(current_user, 'is_superuser', False)}")
    
    # Security: Partners only update themselves
    if is_partner:
        if current_user.id != customer_id:
            raise HTTPException(status_code=403, detail="Not authorized to update this profile")
        
        # Validate against Partner Schema
        try:
            update_data_obj = schemas.CustomerUpdatePartner(**customer_in)
            update_data = update_data_obj.dict(exclude_unset=True)
        except Exception as e:
            raise HTTPException(status_code=422, detail=f"Invalid data for partner profile: {str(e)}")
            
    elif current_user.is_superuser:
        # Validate against Admin Schema
        try:
            update_data_obj = schemas.CustomerUpdateAdmin(**customer_in)
            update_data = update_data_obj.dict(exclude_unset=True)
        except Exception as e:
            raise HTTPException(status_code=422, detail=f"Invalid data for admin update: {str(e)}")
    else:
        raise HTTPException(status_code=403, detail="Not enough privileges")
    
    if "tax_id" in update_data and update_data["tax_id"]:
        customer.status = "submitted" # Signal to admin
    
    print(f"DEBUG: Updating customer {customer.id} with data {update_data}")
    for field, value in update_data.items():
        setattr(customer, field, value)
    
    db.add(customer)
    db.commit()
    db.refresh(customer)
    return customer

@router.post("/{customer_id}/verify", response_model=schemas.Customer)
def verify_partner(
    *,
    db: Session = Depends(deps.get_db),
    customer_id: int,
    current_user: models.User = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Verify a business partner (Staff Only).
    """
    customer = db.query(models.Customer).filter(models.Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Partner not found")
    
    customer.is_verified = True
    customer.status = "verified"
    customer.is_active = True
    
    db.add(customer)
    db.commit()
    db.refresh(customer)
    return customer


@router.post("/{customer_id}/suspend", response_model=schemas.Customer)
def suspend_partner(
    *,
    db: Session = Depends(deps.get_db),
    customer_id: int,
    current_user: models.User = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Suspend a business partner (Staff Only).
    """
    customer = db.query(models.Customer).filter(models.Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Partner not found")
    
    customer.is_verified = False
    customer.status = "suspended"
    customer.is_active = False # Immediately block login
    
    db.add(customer)
    db.commit()
    db.refresh(customer)
    return customer


# --- Customer Memberships ---
@router.post("/{customer_id}/membership", response_model=schemas.Membership)
def assign_membership(
    customer_id: int,
    membership_in: schemas.MembershipCreate,
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_active_user),
):
    """
    Assign or update membership for a customer.
    - Staff (Superuser): Can assign to anyone.
    - Partner: Can only assign to self.
    """
    # Security: Partners only update themselves
    if getattr(current_user, "identity_type", None) == "partner":
        if current_user.id != customer_id:
            raise HTTPException(status_code=403, detail="Not authorized to update this profile")
    elif not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="Not enough privileges")

    customer = db.query(models.Customer).filter(models.Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    
    plan = db.query(models.MembershipPlan).filter(models.MembershipPlan.id == membership_in.plan_id).first()
    if not plan:
        raise HTTPException(status_code=404, detail="Membership plan not found")
    
    # Calculate dates if not provided
    start_date = membership_in.start_date or datetime.date.today()
    end_date = membership_in.end_date or (start_date + datetime.timedelta(days=plan.duration_days))
    
    # Check if existing membership
    membership = db.query(models.Membership).filter(models.Membership.customer_id == customer_id).first()
    if membership:
        membership.plan_id = membership_in.plan_id
        membership.start_date = start_date
        membership.end_date = end_date
        membership.is_active = True
    else:
        membership = models.Membership(
            customer_id=customer_id,
            plan_id=membership_in.plan_id,
            start_date=start_date,
            end_date=end_date,
            is_active=True
        )
        db.add(membership)
    
    db.commit()
    db.refresh(membership)
    return membership

@router.get("/{customer_id}/membership", response_model=schemas.Membership)
def read_customer_membership(
    customer_id: int,
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_active_user),
):
    """
    Get membership details for a customer
    """
    # Security check (Partners only themselves)
    if getattr(current_user, "identity_type", None) == "partner" and current_user.id != customer_id:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    membership = db.query(models.Membership).filter(models.Membership.customer_id == customer_id).first()
    if not membership:
        raise HTTPException(status_code=404, detail="No membership found for this customer")
    return membership

@router.delete("/{customer_id}/membership", response_model=schemas.Membership)
def cancel_membership(
    customer_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_superuser),
):
    """
    Cancel membership for a customer (Admin only)
    """
    membership = db.query(models.Membership).filter(models.Membership.customer_id == customer_id).first()
    if not membership:
        raise HTTPException(status_code=404, detail="No membership found")
    
    db.delete(membership)
    db.commit()
    return membership


@router.delete("/{customer_id}", response_model=schemas.Customer)
def delete_customer(
    *,
    db: Session = Depends(deps.get_db),
    customer_id: int,
    current_user: models.User = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Delete a customer.
    """
    customer = db.query(models.Customer).filter(models.Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    db.delete(customer)
    db.commit()
    return customer


# --- Password Reset Flow ---

@router.post("/password-reset-request")
def request_password_reset(
    request: schemas.PasswordResetRequest,
    db: Session = Depends(deps.get_db)
):
    """
    Generate an OTP for password reset and mock send it.
    """
    customer = db.query(models.Customer).filter(models.Customer.email == request.email).first()
    if not customer:
        # Security: Don't reveal if user exists, but for demo we can or just return success
        return {"message": "If the email exists, an OTP has been sent."}
    
    # Generate 6-digit OTP
    otp = str(random.randint(100000, 999999))
    customer.otp_code = otp
    customer.otp_expiry = datetime.datetime.utcnow() + timedelta(minutes=10)
    
    db.add(customer)
    db.commit()
    
    # Send OTP via Email
    from app.services.email import email_service
    email_sent = email_service.send_password_reset_email(customer.email, customer.name, otp)
    
    if not email_sent:
        # Fallback: Print to console if email service is not configured
        print(f"DEBUG: OTP for {customer.email} is {otp}")
    
    return {"message": "OTP sent successfully to registered email/phone."}

@router.post("/password-reset-confirm")
def confirm_password_reset(
    request: schemas.PasswordResetConfirm,
    db: Session = Depends(deps.get_db)
):
    """
    Verify OTP and update password.
    """
    customer = db.query(models.Customer).filter(models.Customer.email == request.email).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    
    # Verify OTP
    if not customer.otp_code or customer.otp_code != request.otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")
    
    # Verify Expiry
    if not customer.otp_expiry or customer.otp_expiry < datetime.datetime.utcnow():
        raise HTTPException(status_code=400, detail="OTP has expired")
    
    # Update Password (Pydantic already validated length and match)
    customer.hashed_password = security.get_password_hash(request.new_password)
    
    # Clear OTP
    customer.otp_code = None
    customer.otp_expiry = None
    
    db.add(customer)
    db.commit()
    
    return {"message": "Password updated successfully. You can now login with your new password."}

# --- Registration & Approval Flow ---

@router.post("/register", response_model=schemas.Customer)
def apply_for_account(
    application: schemas.CustomerApply,
    db: Session = Depends(deps.get_db)
):
    """
    Public Endpoint: Submit a new business application.
    Status will be 'submitted' pending admin approval.
    """
    # Check existing
    existing = db.query(models.Customer).filter(models.Customer.email == application.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="An application with this email already exists.")
    
    # Create Customer (Placeholder password until approved)
    customer = models.Customer(
        name=application.name,
        email=application.email,
        phone=application.phone,
        address=application.address,
        zip_code=application.zip_code,
        business_name=application.business_name,
        owner_name=application.owner_name,
        tax_id=application.tax_id,
        business_description=application.business_description,
        # Store extras in description/notes if model doesn't support them or ignore for now
        # Creating with status='submitted'
        status="submitted",
        is_verified=False,
        is_active=True,
        hashed_password=security.get_password_hash(application.password), 
        billing_cycle=application.billing_cycle or "weekly",
        customer_type="b2b"
    )
    db.add(customer)
    db.commit()
    db.refresh(customer)
    
    # Notify Admins (Mock)
    print(f"🔔 NEW APPLICATION: {customer.business_name} ({customer.email})")
    
    return customer

@router.post("/{customer_id}/approve")
def approve_application(
    customer_id: int,
    onboarding: schemas.CustomerApprove,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_staff)
):
    """
    Approve a submitted application and onboard the customer.
    1. Updates Customer status to 'verified' and applies credit limit/group.
    2. Creates a User account for login using the customer's existing password.
    """
    customer = db.query(models.Customer).filter(models.Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    
    if customer.status == "verified":
         raise HTTPException(status_code=400, detail="Customer is already verified")

    # 1. Update Customer with Onboarding Data
    customer.status = "verified"
    customer.is_verified = True
    customer.is_active = True
    
    if onboarding.credit_limit is not None:
        customer.credit_limit = onboarding.credit_limit
    if onboarding.group_id is not None:
        customer.group_id = onboarding.group_id
    if onboarding.customer_type is not None:
        customer.customer_type = onboarding.customer_type
    if onboarding.billing_cycle is not None:
        customer.billing_cycle = onboarding.billing_cycle
    
    # 2. Create User Account (if not exists)
    from app.core.roles import ROLE_CUSTOMER, get_role_permissions
    existing_user = db.query(models.User).filter(models.User.email == customer.email).first()
    
    if not existing_user:
        user = models.User(
            email=customer.email,
            full_name=customer.name,
            hashed_password=customer.hashed_password, # Use the password set during registration
            is_active=True,
            role=ROLE_CUSTOMER,
            permissions=get_role_permissions(ROLE_CUSTOMER),
        )
        db.add(user)
    else:
        # Update existing user if needed (e.g. was inactive)
        existing_user.hashed_password = customer.hashed_password
        existing_user.is_active = True
        
    db.commit()
    
    print(f"📧 EMAIL SENT TO {customer.email}: Your B2B Account is Approved!")
    
    return {
        "status": "success",
        "message": "Application approved and customer onboarded successfully",
        "customer_id": customer.id
    }

@router.post("/{customer_id}/reject")
def reject_application(
    customer_id: int,
    reason: str = Body(..., embed=True),
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_staff)
):
    """
    Reject an application. Status -> 'rejected'.
    """
    customer = db.query(models.Customer).filter(models.Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
        
    customer.status = "rejected"
    customer.is_active = False
    
    db.commit()
    
    print(f"🚫 EMAIL SENT TO {customer.email}: Application Rejected. Reason: {reason}")
    
    return {"message": "Application rejected"}

@router.post("/bulk-import", response_model=schemas.CustomerBulkImportResult)
def bulk_import_customers(
    *,
    db: Session = Depends(deps.get_db),
    customers_in: List[schemas.CustomerBulkImport],
    current_user: models.User = Depends(deps.get_current_active_staff)
) -> Any:
    """
    Bulk import customers from CSV (Staff Only).
    Matches by email or phone. Updates if exists, creates if not.
    """
    successful = 0
    failed = 0
    errors = []

    for idx, c_in in enumerate(customers_in):
        try:
            # Check existing by email or phone
            customer = None
            if c_in.email:
                customer = db.query(models.Customer).filter(models.Customer.email == c_in.email).first()
            
            if not customer and c_in.phone:
                customer = db.query(models.Customer).filter(models.Customer.phone == c_in.phone).first()

            if customer:
                # Update existing
                customer.name = c_in.name or customer.name
                if c_in.email:
                    customer.email = c_in.email
                if c_in.phone:
                    customer.phone = c_in.phone
                if c_in.business_name:
                    customer.business_name = c_in.business_name
                if c_in.zip_code:
                    customer.zip_code = c_in.zip_code
                if c_in.customer_type:
                    customer.customer_type = c_in.customer_type
                
                db.add(customer)
                successful += 1
            else:
                # Create new
                pwd = security.get_password_hash("default_password_pending_reset")
                new_customer = models.Customer(
                    name=c_in.name,
                    email=c_in.email,
                    phone=c_in.phone,
                    business_name=c_in.business_name,
                    zip_code=c_in.zip_code,
                    customer_type=c_in.customer_type or "b2b",
                    hashed_password=pwd,
                    status="verified",
                    is_verified=True,
                    is_active=True,
                )
                db.add(new_customer)
                # Let's flush instead of commit on every row to catch DB errors per row if strict, 
                # but adding to session is fine for a final commit
                successful += 1
        except Exception as e:
            failed += 1
            errors.append(f"Row {idx+1} ({c_in.email}): {str(e)}")

    try:
        db.commit()
    except Exception as e:
        db.rollback()
        return schemas.CustomerBulkImportResult(
            successful=0, 
            failed=len(customers_in), 
            errors=[f"Database commit error: {str(e)}"]
        )
        
    return schemas.CustomerBulkImportResult(
        successful=successful,
        failed=failed,
        errors=errors
    )
