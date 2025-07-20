# src/schemas/chatbot_schema.py
from pydantic import BaseModel

class ChatInput(BaseModel):
    message: str
    user_id: str # To potentially personalize responses or log conversations

class ChatOutput(BaseModel):
    response: str
