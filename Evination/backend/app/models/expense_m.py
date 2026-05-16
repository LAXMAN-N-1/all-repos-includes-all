from sqlalchemy import Column, Integer, String, Float, Date, ForeignKey
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel
from datetime import date

class Expense(BaseModel):
    __tablename__ = "expenses"

    title = Column(String(255), nullable=False)
    amount = Column(Float, nullable=False)
    category = Column(String(100), nullable=False) # e.g., "Marketing", "Server", "Salaries"
    expense_date = Column(Date, default=date.today)
    reference_id = Column(String(100), nullable=True) # Invoice number etc.
    
    created_by_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    
    # Relationships
    created_by = relationship("User", backref="expenses")
