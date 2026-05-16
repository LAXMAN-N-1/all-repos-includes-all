from typing import Optional, List
from pydantic import BaseModel
from datetime import datetime

class WalletTransactionBase(BaseModel):
    amount: float
    transaction_type: str
    reference_id: Optional[str] = None
    notes: Optional[str] = None

class WalletTransactionCreate(WalletTransactionBase):
    customer_id: int

class WalletTransaction(WalletTransactionBase):
    id: int
    customer_id: int
    created_at: datetime

    class Config:
        from_attributes = True

class WalletDeposit(BaseModel):
    amount: float
    notes: Optional[str] = None

class WalletBalance(BaseModel):
    customer_id: int
    wallet_balance: float
