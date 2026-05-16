from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum

class SenderType(str, Enum):
    USER = "user"
    AI = "ai"
    SYSTEM = "system"

class MessageBase(BaseModel):
    content: str
    sender: SenderType
    audio_url: Optional[str] = None
    meta_data: Optional[Dict[str, Any]] = None

class MessageCreate(MessageBase):
    pass

class MessageResponse(MessageBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True

class ConversationBase(BaseModel):
    language_code: Optional[str] = "en"

class ConversationCreate(ConversationBase):
    user_id: Optional[int] = None

class ConversationResponse(ConversationBase):
    id: int
    status: str
    started_at: datetime
    messages: List[MessageResponse] = []
    
    class Config:
        from_attributes = True

class ChatRequest(BaseModel):
    conversation_id: Optional[int] = None
    user_id: Optional[int] = None # Optional, if guest
    message: str # Text input (or transcribed text)
    audio_url: Optional[str] = None # If it was a voice message
    language: Optional[str] = "en"

class ProductRecommendation(BaseModel):
    product_id: int
    product_name: str
    reason: str
    relevance_score: int

class ChatResponse(BaseModel):
    conversation_id: int
    response_text: str
    audio_url: Optional[str] = None # TTS output
    suggested_actions: List[str] = [] # ["Buy Paracetamol", "Consult Doctor"]
    recommendations: List[ProductRecommendation] = []
    
    # Internal debug info
    detected_intent: Optional[str] = None
