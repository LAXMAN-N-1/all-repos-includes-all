from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app import models, schemas
from app.api import deps

router = APIRouter()

@router.get("/", response_model=List[schemas.Location])
def read_locations(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve locations.
    partners: View only their own locations.
    staff: View all locations (or filter by customer_id if provided).
    """
    if getattr(current_user, "identity_type", None) == "partner":
        locations = db.query(models.Location).filter(
            models.Location.customer_id == current_user.id
        ).offset(skip).limit(limit).all()
    else:
        # For staff, we could add filtering, but for now return all or maybe just return empty list as fail safe
        # Ideally staff would fetch locations via /customers/{id}/locations
        locations = db.query(models.Location).offset(skip).limit(limit).all()
        
    return locations

@router.post("/", response_model=schemas.Location)
def create_location(
    *,
    db: Session = Depends(deps.get_db),
    location_in: schemas.LocationCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create new location.
    """
    if getattr(current_user, "identity_type", None) == "partner":
        customer_id = current_user.id
    else:
        # Staff creating location? Ideally they should specify customer_id, 
        # but the schema doesn't have it yet. 
        # For MVP, let's assume this is Partner logic mainly.
        raise HTTPException(status_code=400, detail="Staff creation of locations not fully implemented")

    location = models.Location(
        **location_in.dict(),
        customer_id=customer_id
    )
    db.add(location)
    db.commit()
    db.refresh(location)
    return location


@router.get("/{id}", response_model=schemas.Location)
def read_location(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get location by ID.
    Partners can only view their own locations.
    """
    location = db.query(models.Location).filter(models.Location.id == id).first()
    if not location:
        raise HTTPException(status_code=404, detail="Location not found")
        
    # Authorization check for partners
    if getattr(current_user, "identity_type", None) == "partner":
        if location.customer_id != current_user.id:
            raise HTTPException(status_code=403, detail="Not authorized to view this location")
            
    return location


@router.put("/{id}", response_model=schemas.Location)
def update_location(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    location_in: schemas.LocationUpdate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update a location.
    Partners can only update their own locations.
    """
    location = db.query(models.Location).filter(models.Location.id == id).first()
    if not location:
        raise HTTPException(status_code=404, detail="Location not found")
        
    # Authorization check for partners
    if getattr(current_user, "identity_type", None) == "partner":
        if location.customer_id != current_user.id:
            raise HTTPException(status_code=403, detail="Not authorized to update this location")
    
    # Update location fields
    update_data = location_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(location, field, value)
    
    db.add(location)
    db.commit()
    db.refresh(location)
    return location

@router.delete("/{id}", response_model=schemas.Location)
def delete_location(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Delete a location.
    """
    location = db.query(models.Location).filter(models.Location.id == id).first()
    if not location:
        raise HTTPException(status_code=404, detail="Location not found")
        
    if getattr(current_user, "identity_type", None) == "partner":
        if location.customer_id != current_user.id:
            raise HTTPException(status_code=403, detail="Not authorized")
            
    db.delete(location)
    db.commit()
    return location
