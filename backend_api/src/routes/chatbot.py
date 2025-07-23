from fastapi import APIRouter, Depends, HTTPException
from src.schemas.chatbot_schema import ChatInput, ChatOutput
from src.services.ai_chatbot_service import chat_with_bot
from uuid import UUID # Ensure UUID is imported

router = APIRouter()

@router.post("/chat", response_model=ChatOutput)
async def chat_endpoint(chat_input: ChatInput):
    """
    Provides 24/7 AI chatbot support.
    """
    try:
        # Convert UUID to string for the service function if it expects a string
        # The chat_with_bot service function needs to be updated to accept user_id
        response_text = await chat_with_bot(chat_input.message, str(chat_input.user_id))
        return ChatOutput(response=response_text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Chatbot error: {e}")
