from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.ai import ChatRequest, ChatResponse, ProductRecommendation
from app.models.customer_ai import Conversation, Message, ConversationStatus, MessageSender
from app.services.ai.voice_service import voice_service
from app.services.ai.nlu_service import nlu_service
from app.services.ai.medical_service import medical_service
import json

router = APIRouter()

from app.services.ai.medical_service_advanced import medical_decision_tree
from app.services.ai.translation_service import translation_service

# ... imports ...

@router.post("/chat", response_model=ChatResponse)
async def chat_interaction(request: ChatRequest, db: Session = Depends(get_db)):
    
    # 1. Get/Create Conversation
    if request.conversation_id:
        conversation = db.query(Conversation).filter(Conversation.id == request.conversation_id).first()
        if not conversation:
            raise HTTPException(status_code=404, detail="Conversation not found")
    else:
        conversation = Conversation(user_id=request.user_id, language_code=request.language)
        db.add(conversation)
        db.commit()
        db.refresh(conversation)

    # 2. Record User Message
    user_msg = Message(
        conversation_id=conversation.id,
        sender=MessageSender.USER,
        content=request.message,
        audio_url=request.audio_url
    )
    db.add(user_msg)
    
    # 3. Process Interaction
    current_context = conversation.context_data or {}
    
    # --- NEW GEMINI LOGIC ---
    from app.services.ai.gemini_service import gemini_service
    
    # Generate Response using Gemini (Real AI) - Native Multilingual Support
    ai_result = gemini_service.generate_response(request.message, current_context, language=request.language)
    
    response_text = ai_result.get('response_text', "I didn't understand.")
    action = ai_result.get('action', 'advice')
    recommendations_data = ai_result.get('recommendations', [])
    
    # Update Context
    current_context['last_action'] = action
    conversation.context_data = current_context
    db.add(conversation) # Add conversation to session for update
    db.commit() # Commit context update

    # Format Recommendations
    # Map Gemini Output to Response Variables
    formatted_recs = []
    for item in recommendations_data:
        formatted_recs.append(ProductRecommendation(
            product_id=1, 
            product_name=item.get('product_name', 'Medicine'),
            reason=item.get('reason', 'Contextual Match'),
            relevance_score=item.get('relevance_score', 90)
        ))

    # Define variables for Response construction
    intent = action 
    recommendations = formatted_recs
    suggested_actions = ["Add to Cart", "Consult Doctor"] if intent == 'RECOMMEND_CART' else ["Ask something else"]

    # 4. No need for back-translation, Gemini handles it.
    final_response_text = response_text

    # 5. Record AI Response
    ai_msg = Message(
        conversation_id=conversation.id,
        sender=MessageSender.AI,
        content=final_response_text,
        meta_data={"intent": intent, "orig_response": response_text}
    )
    db.add(ai_msg)
    db.commit()

    return ChatResponse(
        conversation_id=conversation.id,
        response_text=final_response_text,
        recommendations=recommendations,
        suggested_actions=suggested_actions,
        detected_intent=intent
    )

@router.post("/chat-audio", response_model=ChatResponse)
async def chat_audio_interaction(
    audio: UploadFile = File(...),
    user_id: int = 1,
    language: str = "en",
    conversation_id: int = None,
    db: Session = Depends(get_db)
):
    # 0. Read Audio
    audio_bytes = await audio.read()
    
    # 1. Get/Create Conversation
    if conversation_id:
        conversation = db.query(Conversation).filter(Conversation.id == conversation_id).first()
        if not conversation:
            raise HTTPException(status_code=404, detail="Conversation not found")
    else:
        conversation = Conversation(user_id=user_id, language_code=language)
        db.add(conversation)
        db.commit()
        db.refresh(conversation)

    # 2. Record User Message (Audio)
    user_msg = Message(
        conversation_id=conversation.id,
        sender=MessageSender.USER,
        content="[Audio Message]",
        audio_url="uploaded_file" 
    )
    db.add(user_msg)
    
    # 3. Process with Gemini (Audio -> Response)
    current_context = conversation.context_data or {}
    
    from app.services.ai.gemini_service import gemini_service
    ai_result = gemini_service.generate_response(audio_bytes, current_context, language=language)
    
    response_text = ai_result.get('response_text', "I didn't understand.")
    action = ai_result.get('action', 'advice')
    recommendations_data = ai_result.get('recommendations', [])
    
    # Update Context
    current_context['last_action'] = action
    conversation.context_data = current_context
    db.add(conversation)
    db.commit()

    # Format Output
    formatted_recs = []
    for item in recommendations_data:
        formatted_recs.append(ProductRecommendation(
            product_id=1, 
            product_name=item.get('product_name', 'Medicine'),
            reason=item.get('reason', 'Contextual Match'),
            relevance_score=item.get('relevance_score', 90)
        ))

    intent = action 
    recommendations = formatted_recs
    suggested_actions = ["Add to Cart", "Consult Doctor"] if intent == 'RECOMMEND_CART' else ["Ask something else"]

    # 5. Record AI Response
    ai_msg = Message(
        conversation_id=conversation.id,
        sender=MessageSender.AI,
        content=response_text,
        meta_data={"intent": intent}
    )
    db.add(ai_msg)
    db.commit()

    return ChatResponse(
        conversation_id=conversation.id,
        response_text=response_text,
        recommendations=recommendations,
        suggested_actions=suggested_actions,
        detected_intent=intent
    )
