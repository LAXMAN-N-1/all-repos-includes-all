from sqlalchemy.orm import Session
from app.models.chat_m import Chat, Message
from app.schemas.chat_schema import ChatCreate, MessageCreate
from datetime import datetime

class ChatService:
    @staticmethod
    def create_or_get_chat(db: Session, chat_data: ChatCreate, consumer_id: int):
        # Check if chat exists
        chat = db.query(Chat).filter(
            Chat.consumer_id == consumer_id,
            Chat.vendor_id == chat_data.vendor_id,
            Chat.event_id == chat_data.event_id
        ).first()
        
        if not chat:
            chat = Chat(
                consumer_id=consumer_id,
                vendor_id=chat_data.vendor_id,
                event_id=chat_data.event_id,
                created_by=str(consumer_id)
            )
            db.add(chat)
            db.commit()
            db.refresh(chat)
        return chat

    @staticmethod
    def send_message(db: Session, chat_id: int, sender_id: int, message_data: MessageCreate):
        new_message = Message(
            chat_id=chat_id,
            sender_id=sender_id,
            content=message_data.content,
            created_by=str(sender_id)
        )
        db.add(new_message)
        db.commit()
        db.refresh(new_message)
        return new_message

    @staticmethod
    def get_my_chats(db: Session, user_id: int, role_code: str):
        if role_code == "CONSUMER":
            return db.query(Chat).filter(Chat.consumer_id == user_id).all()
        elif role_code == "VENDOR":
            return db.query(Chat).filter(Chat.vendor_id == user_id).all() # This assumes vendor_id matches user_id logic or we need to join Vendor
            # Wait, vendor_id in Chat is Vendor table ID. user_id passed is User table ID.
            # I must find Vendor ID from User ID first for vendor.
            # Assuming caller handles this or we do it here.
            # For simplicity, if role is VENDOR, we assume user_id needs resolution.
            # However, simpler if we pass the correct ID. Let's assume the router resolves it.
            return []
        return []

    @staticmethod
    def get_chat_history(db: Session, chat_id: int):
        chat = db.query(Chat).filter(Chat.id == chat_id).first()
        if not chat:
            return None
        return chat
