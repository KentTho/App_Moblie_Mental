# src/routes/chatbot.py
from fastapi import APIRouter, Depends, HTTPException
from src.schemas.chatbot_schema import ChatInput, ChatOutput
from src.services.ai_chatbot_service import chat_with_bot

router = APIRouter()

@router.post("/chat", response_model=ChatOutput)
async def chat_endpoint(chat_input: ChatInput):
    """
    Provides 24/7 AI chatbot support.
    """
    try:
        response_text = await chat_with_bot(chat_input.message)
        return ChatOutput(response=response_text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Chatbot error: {e}")
