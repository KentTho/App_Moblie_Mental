from pydantic import BaseModel

class ChatInput(BaseModel):
    message: str
    user_id: str # Changed from str to UUID

class ChatOutput(BaseModel):
    response: str
