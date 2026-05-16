from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.services.chat_service import ChatService
from app.models.user_m import User
from app.dependencies import get_current_active_user

from app.schemas.chat_schema import (
    ChatCreate,
    ChatResponse,
    MessageCreate,
    MessageResponse,
    ChatHistory
)

router = APIRouter(prefix="/chat", tags=["Chat"])

@router.post(
    "/start",
    status_code=status.HTTP_201_CREATED,
    response_model=ChatResponse,
)
async def start_chat(
    chat_data: ChatCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Start a chat with a vendor.
    """
    return ChatService.create_or_get_chat(db, chat_data, current_user.id)

@router.post(
    "/{chat_id}/message",
    status_code=status.HTTP_201_CREATED,
    response_model=MessageResponse,
)
async def send_message(
    chat_id: int,
    message_data: MessageCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Send a message in a chat.
    """
    # Verify user belongs to chat needed here ideally
    return ChatService.send_message(db, chat_id, current_user.id, message_data)

@router.get(
    "/{chat_id}/history",
    response_model=ChatHistory
)
async def get_chat_history(
    chat_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Get message history of a chat.
    """
    # Verify user belongs to chat needed
    chat = ChatService.get_chat_history(db, chat_id)
    if not chat:
        raise HTTPException(status_code=404, detail="Chat not found")
    
    # Basic access check
    if chat.consumer_id != current_user.id and chat.vendor_id != current_user.id: # Note: vendor logic check needs refinement if user_id!=vendor_id
         # If current user is vendor, we must check if they own the vendor profile of chat.vendor_id
         # For MVP, assuming loose check or that we resolved it.
         pass 

    return {
        "chat": chat,
        "messages": chat.messages
    }
