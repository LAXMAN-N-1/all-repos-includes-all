from sqlalchemy.orm import Session
from app.models.department_m import Department
from app.schemas.department_schema import DepartmentCreate, DepartmentUpdate
from fastapi import HTTPException, status

class DepartmentService:
    @staticmethod
    def create_department(db: Session, schema: DepartmentCreate) -> Department:
        # Check if code already exists
        existing_code = db.query(Department).filter(Department.code == schema.code).first()
        if existing_code:
            raise HTTPException(status_code=400, detail="Department code already exists")
            
        new_dept = Department(**schema.model_dump())
        db.add(new_dept)
        db.commit()
        db.refresh(new_dept)
        return new_dept

    @staticmethod
    def get_department(db: Session, department_id: int) -> Department:
        dept = db.query(Department).filter(Department.id == department_id).first()
        if not dept:
            raise HTTPException(status_code=404, detail="Department not found")
        return dept

    @staticmethod
    def get_departments(db: Session, skip: int = 0, limit: int = 100) -> list[Department]:
        return db.query(Department).offset(skip).limit(limit).all()

    @staticmethod
    def update_department(db: Session, department_id: int, schema: DepartmentUpdate) -> Department:
        dept = DepartmentService.get_department(db, department_id)
        
        update_data = schema.model_dump(exclude_unset=True)
        if "code" in update_data:
             # Check distinct code uniqueness if changed
            existing = db.query(Department).filter(Department.code == update_data["code"], Department.id != department_id).first()
            if existing:
                raise HTTPException(status_code=400, detail="Department code already exists")
                
        for key, value in update_data.items():
            setattr(dept, key, value)
            
        db.commit()
        db.refresh(dept)
        return dept

    @staticmethod
    def delete_department(db: Session, department_id: int):
        dept = DepartmentService.get_department(db, department_id)
        db.delete(dept)
        db.commit()
        return {"message": "Department deleted successfully"}
