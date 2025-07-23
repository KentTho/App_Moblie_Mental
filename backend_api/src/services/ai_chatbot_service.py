import os
from transformers import pipeline, set_seed
from dotenv import load_dotenv
from typing import Optional # Import Optional

load_dotenv()

# Set a seed for reproducibility
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
    print(f"❌ Failed to load Hugging Face Chatbot model: {e}")
    print("Please ensure 'torch' or 'tensorflow' and 'transformers' are installed.")
    print("Also, check your internet connection for model download.")


async def chat_with_bot(user_message: str, user_id: Optional[str] = None) -> str: # Added user_id parameter
    """
    Interacts with the Hugging Face conversational AI model.
    """
    if not user_message.strip() or not chatbot_pipeline:
        return "I'm sorry, I couldn't process your request. The chatbot model might not be loaded or your message is empty."

    try:
        from transformers import Conversation
        # You can use user_id here for logging or personalization if needed
        conversation = Conversation(user_message)
        response = chatbot_pipeline(conversation)
        return response.generated_responses[-1]
    except Exception as e:
        print(f"❌ Error during chatbot interaction: {e}")
        return "I'm sorry, I encountered an error while processing your request. Please try again later."
