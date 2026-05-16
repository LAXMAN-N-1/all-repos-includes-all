from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class MessageBase(BaseModel):
    content: str

class MessageCreate(MessageBase):
    pass

class MessageResponse(MessageBase):
    id: int
    sender_id: int
    timestamp: datetime
    
    class Config:
        from_attributes = True

class ChatCreate(BaseModel):
    vendor_id: int
    event_id: Optional[int] = None

class ChatResponse(BaseModel):
    id: int
    vendor_id: int
    consumer_id: int
    event_id: Optional[int]
    created_at: datetime
    last_message: Optional[MessageResponse] = None
    
    class Config:
        from_attributes = True

class ChatHistory(BaseModel):
    chat: ChatResponse
    messages: List[MessageResponse]
