# src/routes/charts.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func, extract
from src.db.database import get_db
from src.models.notes import Note
from src.schemas.chart_schema import EmotionChartResponse, EmotionDataPoint
from typing import List, Dict
from collections import defaultdict
from datetime import date, timedelta

router = APIRouter()

@router.get("/emotions-over-time/{user_id}", response_model=EmotionChartResponse)
def get_emotions_over_time(user_id: str, db: Session = Depends(get_db)):
    """
    Retrieves emotion data over time for a specific user, aggregated by date.
    """
    notes = db.query(Note).filter(Note.user_id == user_id).order_by(Note.created_at).all()

    if not notes:
        return EmotionChartResponse(data=[])

    # Aggregate emotions by date
    daily_emotion_counts: Dict[date, Dict[str, int]] = defaultdict(lambda: defaultdict(int))

    for note in notes:
        note_date = note.created_at.date()
        if note.emotions:
            for emotion in note.emotions:
                daily_emotion_counts[note_date][emotion] += 1

    # Convert to a list of EmotionDataPoint, ensuring all dates are present (optional, but good for charts)
    # Find min and max dates to fill in missing days
    min_date = min(daily_emotion_counts.keys())
    max_date = max(daily_emotion_counts.keys())

    chart_data: List[EmotionDataPoint] = []
    current_date = min_date
    while current_date <= max_date:
        chart_data.append(
            EmotionDataPoint(
                date=current_date,
                emotion_counts=daily_emotion_counts[current_date]
            )
        )
        current_date += timedelta(days=1)

    return EmotionChartResponse(data=chart_data)
