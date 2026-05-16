from sqlalchemy import Column, String, Integer, Float, ForeignKey, DateTime, Date, Enum as SQLEnum, Text, Time
from sqlalchemy.orm import relationship
import enum
from app.models.base import BaseModel

class EmployeeType(str, enum.Enum):
    FULL_TIME = "FULL_TIME"
    PART_TIME = "PART_TIME"
    CONTRACT = "CONTRACT"

class Employee(BaseModel):
    """
    HR Profile for Staff members.
    Linked to User account for login.
    """
    __tablename__ = "employees"

    user_id = Column(Integer, ForeignKey('users.id'), unique=True, nullable=False)
    store_id = Column(Integer, ForeignKey('stores.id'), nullable=True) # Home store
    
    employee_code = Column(String(50), unique=True, nullable=False)
    designation = Column(String(100))
    department = Column(String(100))
    type = Column(SQLEnum(EmployeeType), default=EmployeeType.FULL_TIME)
    
    join_date = Column(Date, nullable=False)
    resignation_date = Column(Date, nullable=True)
    
    salary_base = Column(Float, default=0.0)
    bank_account_details = Column(Text) # JSON or Encrypted String in real app

    # Relationships
    user = relationship("User", backref="employee_profile")
    store = relationship("Store")


class Attendance(BaseModel):
    """
    Daily attendance logs.
    """
    __tablename__ = "attendance"

    employee_id = Column(Integer, ForeignKey('employees.id'), nullable=False)
    store_id = Column(Integer, ForeignKey('stores.id'), nullable=False)
    
    date = Column(Date, nullable=False, index=True)
    clock_in = Column(DateTime(timezone=True))
    clock_out = Column(DateTime(timezone=True))
    
    status = Column(String(20), default="PRESENT") # PRESENT, ABSENT, LEAVE, LATE
    
    # Relationships
    employee = relationship("Employee", backref="attendance_logs")


class Shift(BaseModel):
    """
    Work schedules.
    """
    __tablename__ = "shifts"

    name = Column(String(50)) # Morning, Evening, Night
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)
    
    store_id = Column(Integer, ForeignKey('stores.id'), nullable=True) # If shift is store-specific
