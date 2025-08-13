# src/services/suggestion_service.py

import json
from pathlib import Path
from typing import List, Optional
from src.schemas.suggestion_schema import SuggestionItem

SUGGESTION_DATA_PATH = Path("src/data/suggestions_data.json")


def load_suggestions_from_file() -> List[dict]:
    if not SUGGESTION_DATA_PATH.exists():
        raise FileNotFoundError(f"Suggestions data file not found at {SUGGESTION_DATA_PATH}")

    with SUGGESTION_DATA_PATH.open("r", encoding="utf-8") as f:
        return json.load(f)


def get_suggestions(emotion: Optional[str] = None) -> List[SuggestionItem]:
    raw_data = load_suggestions_from_file()
    filtered_suggestions = []

    emotion = emotion.lower() if emotion else None

    for item in raw_data:
        item_emotions = [e.lower() for e in item.get("emotion", [])]

        # Nếu không truyền emotion => lấy những suggestion chung (emotion rỗng)
        if not emotion:
            if not item_emotions:  # general suggestions
                filtered_suggestions.append(SuggestionItem(**item))
        else:
            # Nếu cảm xúc có khớp trong danh sách thì lấy
            if not item_emotions or emotion in item_emotions:
                filtered_suggestions.append(SuggestionItem(**item))

    return filtered_suggestions
