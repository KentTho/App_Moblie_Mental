from pydantic import BaseModel
from typing import List
from datetime import datetime

class NoteCreate(BaseModel):
    user_id: str
    title: str
    content: str
    tags: List[str]

class NoteUpdate(BaseModel):
    title: str
    content: str
    tags: List[str]

class NoteOut(BaseModel):
    id: str
    user_id: str
    title: str
    content: str
    tags: List[str]
    sentiment: str | None
    created_at: datetime
    updated_at: datetime

    model_config = {
        "from_attributes": True
    }