# src/routes/chatbot_route.py (tên file bạn đang dùng)

from fastapi import APIRouter, HTTPException
from src.schemas.chatbot_schema import ChatInput, ChatOutput
from src.services.ai_chatbot_service import chat_with_bot
from uuid import UUID

router = APIRouter(prefix="/api/chatbot", tags=["Chatbot"])

@router.post("/chat", response_model=ChatOutput)
async def chat_endpoint(chat_input: ChatInput):
    try:
        print("Received chat input:", chat_input)
        response_text = await chat_with_bot(chat_input.message, str(chat_input.user_id))
        return ChatOutput(response=response_text)
    except Exception as e:
        print("❌ Chatbot error:", e)
        raise HTTPException(status_code=500, detail=f"Chatbot error: {e}")
