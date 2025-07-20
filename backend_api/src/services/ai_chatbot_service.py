# src/services/ai_chatbot_service.py
import os
from transformers import pipeline, set_seed
from dotenv import load_dotenv

load_dotenv()

# Set a seed for reproducibility
set_seed(42)

# --- Hugging Face Chatbot Model ---
# Using a general conversational model. For a Vietnamese-specific chatbot,
# a different model trained on Vietnamese conversations would be needed.
# 'microsoft/DialoGPT-medium' is a good starting point for English.
# For Vietnamese, you might need to find a specialized model or fine-tune one.
try:
    # Using a smaller, more general model for demonstration in a sandbox.
    # For production, consider a more robust conversational model.
    # Example: 'microsoft/DialoGPT-small' or 'facebook/blenderbot-400M-distill'
    # Note: These are primarily English models.
    chatbot_pipeline = pipeline(
        "text-generation",
        model="microsoft/DialoGPT-small",
        tokenizer="microsoft/DialoGPT-small"
    )
    print("✅ Hugging Face Chatbot model loaded successfully.")
except Exception as e:
    chatbot_pipeline = None
    print(f"❌ Failed to load Hugging Face Chatbot model: {e}")
    print("Please ensure 'torch' or 'tensorflow' and 'transformers' are installed.")
    print("Also, check your internet connection for model download.")


async def chat_with_bot(user_message: str) -> str:
    if not user_message.strip() or not chatbot_pipeline:
        return "I'm sorry, I couldn't process your request."

    try:
        response = chatbot_pipeline(
            user_message,
            max_length=100,
            num_return_sequences=1,
            pad_token_id=50256  # for DialoGPT
        )
        return response[0]["generated_text"]
    except Exception as e:
        print(f"❌ Error during chatbot interaction: {e}")
        return "I'm sorry, I encountered an error while processing your request."
