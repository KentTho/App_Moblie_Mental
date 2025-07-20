# src/routes/suggestions.py
from fastapi import APIRouter, Depends, Query
from src.schemas.suggestion_schema import SuggestionsResponse
from src.services.suggestion_service import get_suggestions
from typing import Optional

router = APIRouter()

@router.get("/", response_model=SuggestionsResponse)
def get_exercise_suggestions(
    emotion: Optional[str] = Query(None, description="Filter suggestions by a specific emotion (e.g., 'sadness', 'anger')")
):
    """
    Provides exercise, meditation, music, or article suggestions.
    Can be filtered by a specific emotion.
    """
    suggestions = get_suggestions(emotion=emotion)
    return SuggestionsResponse(suggestions=suggestions)
