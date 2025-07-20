# src/schemas/suggestion_schema.py
from pydantic import BaseModel
from typing import Optional, List

class SuggestionItem(BaseModel):
    type: str # e.g., "meditation", "music", "article"
    title: str
    description: str
    link: Optional[str] = None

class SuggestionsResponse(BaseModel):
    suggestions: List[SuggestionItem]
