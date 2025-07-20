# src/schemas/chart_schema.py
from pydantic import BaseModel
from typing import Dict, List
from datetime import date

class EmotionDataPoint(BaseModel):
    date: date
    emotion_counts: Dict[str, int] # e.g., {"joy": 5, "sadness": 2}

class EmotionChartResponse(BaseModel):
    data: List[EmotionDataPoint]
