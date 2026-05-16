from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.services.department_service import DepartmentService
from app.schemas.department_schema import DepartmentCreate, DepartmentUpdate, DepartmentResponse

router = APIRouter(prefix="/api/admin/departments", tags=["Admin Department Management"])

@router.post("/", response_model=DepartmentResponse)
def create_department(schema: DepartmentCreate, db: Session = Depends(get_db)):
    """Create a new department"""
    return DepartmentService.create_department(db, schema)

@router.get("/", response_model=List[DepartmentResponse])
def get_departments(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """List all departments"""
    return DepartmentService.get_departments(db, skip, limit)

@router.get("/{id}", response_model=DepartmentResponse)
def get_department(id: int, db: Session = Depends(get_db)):
    """Get department details"""
    return DepartmentService.get_department(db, id)

@router.put("/{id}", response_model=DepartmentResponse)
def update_department(id: int, schema: DepartmentUpdate, db: Session = Depends(get_db)):
    """Update department details"""
    return DepartmentService.update_department(db, id, schema)

@router.delete("/{id}")
def delete_department(id: int, db: Session = Depends(get_db)):
    """Delete a department"""
    return DepartmentService.delete_department(db, id)
