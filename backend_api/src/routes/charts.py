from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import date, timedelta
from typing import List, Dict
from collections import defaultdict
from src.db.database import get_db
from src.models.notes import Note
from src.models.user import User
from src.schemas.chart_schema import EmotionChartResponse
from src.dependencies import get_current_user_from_firebase
from sqlalchemy import func  # ⚠️ Thêm dòng import này ở đầu file nếu chưa có

router = APIRouter(prefix="/api/charts", tags=["Charts"])

@router.get("/emotions-over-time/{firebase_uid}", response_model=EmotionChartResponse)
async def get_emotions_over_time(
    firebase_uid: str,
    days: int = 30,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user_from_firebase)
):
    if current_user.firebase_uid != firebase_uid:
        raise HTTPException(status_code=403, detail="Unauthorized access")

    end_date = date.today()
    start_date = end_date - timedelta(days=days)

    # Truy vấn Note từ DB
    notes = db.query(Note).filter(
        Note.user_id == current_user.id,
        func.date(Note.created_at) >= start_date,
        func.date(Note.created_at) <= end_date
    ).order_by(Note.created_at).all()

    print(f"📌 Found {len(notes)} notes for user {current_user.id} from {start_date} to {end_date}")

    daily_stats = defaultdict(lambda: defaultdict(int))
    for note in notes:
        note_date = note.created_at.date()
        emotions = note.emotions or []
        print(f"📝 Note on {note_date} with emotions: {emotions}")

        for emotion in emotions:
            daily_stats[note_date][emotion] += 1

    chart_data = []
    current_date = start_date
    while current_date <= end_date:
        chart_data.append({
            "date": current_date,
            "emotion_counts": dict(daily_stats[current_date])
        })
        current_date += timedelta(days=1)

    print(f"📊 Chart data: {chart_data}")
    return {"data": chart_data}
