# src/services/ai_chatbot_service.py

import os
from transformers import pipeline, set_seed
from dotenv import load_dotenv
from typing import Optional

from src.utils.sentiment_emotion_utils import analyze_sentiment, get_emotion_response

load_dotenv()
set_seed(42)

try:
    chatbot_pipeline = pipeline(
        "text-generation",
        model="microsoft/DialoGPT-small",
        tokenizer="microsoft/DialoGPT-small"
    )
    print("✅ Hugging Face Chatbot model loaded successfully.")
except Exception as e:
    chatbot_pipeline = None
    print(f"❌ Failed to load model: {e}")


async def chat_with_bot(user_message: str, user_id: Optional[str] = None) -> str:
    if not user_message.strip() or not chatbot_pipeline:
        return "Mình xin lỗi, hiện tại mình chưa sẵn sàng trả lời. Bạn hãy thử lại sau nhé."

    try:
        sentiment = analyze_sentiment(user_message)
        emotional_response = get_emotion_response(sentiment)

        # Tạo prompt để model tiếp tục nếu muốn (có thể bỏ)
        prompt = f"User: {user_message}\nAI: {emotional_response}"

        result = chatbot_pipeline(prompt, max_length=100, pad_token_id=50256)
        full_text = result[0]["generated_text"]

        # Trả lại phần cuối (bỏ nếu không dùng pipeline nữa)
        return emotional_response

    except Exception as e:
        print(f"❌ Error: {e}")
        return "Mình gặp trục trặc khi trả lời bạn. Hãy thử lại sau nhé."
