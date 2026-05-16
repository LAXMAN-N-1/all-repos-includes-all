from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime, Boolean, JSON, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from app.database import Base

class ConversationStatus(str, enum.Enum):
    ACTIVE = "active"
    COMPLETED = "completed"
    ARCHIVED = "archived"

class MessageSender(str, enum.Enum):
    USER = "user"
    AI = "ai"
    SYSTEM = "system"

class Conversation(Base):
    __tablename__ = "ai_conversations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True) # Can be guest
    started_at = Column(DateTime, default=datetime.utcnow)
    ended_at = Column(DateTime, nullable=True)
    language_code = Column(String, default="en") # en, te, hi...
    status = Column(Enum(ConversationStatus), default=ConversationStatus.ACTIVE)
    
    # JSON blob for context (e.g. current_symptoms: ['fever'], asked_duration: True)
    context_data = Column(JSON, default={}) 

    messages = relationship("Message", back_populates="conversation")

class Message(Base):
    __tablename__ = "ai_messages"

    id = Column(Integer, primary_key=True, index=True)
    conversation_id = Column(Integer, ForeignKey("ai_conversations.id"))
    sender = Column(Enum(MessageSender))
    content = Column(Text) # Transcribed text or AI response text
    audio_url = Column(String, nullable=True) # If voice message
    
    # Meta data for the message (e.g. detected_intent: "SYMPTOM_CHECK")
    meta_data = Column(JSON, default={})
    
    created_at = Column(DateTime, default=datetime.utcnow)

    conversation = relationship("Conversation", back_populates="messages")

class MedicalCondition(Base):
    """
    Knowledge base for conditions.
    Ex: Condition "Viral Fever"
    """
    __tablename__ = "ai_medical_conditions"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True)
    description = Column(Text)
    
    # Tags/Keywords for NLP matching: ["fever", "high temp", "heating"]
    symptom_keywords = Column(JSON, default=[]) 
    
    # Required questions to ask: ["How many days?", "What is your temp?"]
    triage_questions = Column(JSON, default=[]) 
    
    mappings = relationship("SymptomProductMap", back_populates="condition")

class SymptomProductMap(Base):
    """
    Maps a condition to products.
    Ex: Viral Fever -> Paracetamol 650 (Relevance 0.9)
    """
    __tablename__ = "ai_symptom_product_maps"
    
    id = Column(Integer, primary_key=True, index=True)
    condition_id = Column(Integer, ForeignKey("ai_medical_conditions.id"))
    
    # We reference product ID generically. Ideally FK to Product table if strictly relational
    # But often AI maps might be loose. Let's use loose ID for now or FK if Product is imported.
    # Assuming Product table exists in 'app.models.inventory' or similar, but to avoid circular imports 
    # we might just store integer ID. Let's try Loose Coupling.
    product_id = Column(Integer, nullable=False) 
    
    relevance_score = Column(Integer, default=0) # 0-100
    age_group_min = Column(Integer, default=0)
    age_group_max = Column(Integer, default=120)
    is_prescription_required = Column(Boolean, default=False)
    
    condition = relationship("MedicalCondition", back_populates="mappings")
