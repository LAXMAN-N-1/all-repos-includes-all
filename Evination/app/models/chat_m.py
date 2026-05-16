from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel
from datetime import datetime

class Chat(BaseModel):
    __tablename__ = "chats"

    consumer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=False)
    event_id = Column(Integer, ForeignKey("events.id"), nullable=True)

    consumer = relationship("User", backref="chats")
    vendor = relationship("Vendor", backref="chats")
    event = relationship("Event", backref="chat")
    messages = relationship("Message", back_populates="chat", cascade="all, delete-orphan")

class Message(BaseModel):
    __tablename__ = "messages"

    chat_id = Column(Integer, ForeignKey("chats.id"), nullable=False)
    sender_id = Column(Integer, ForeignKey("users.id"), nullable=False) # Can be consumer or vendor (linked to user_id)
    content = Column(Text, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)

    chat = relationship("Chat", back_populates="messages")
    sender = relationship("User")
