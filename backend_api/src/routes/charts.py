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

router = APIRouter(prefix="/api/charts", tags=["Charts"])


@router.get("/emotions-over-time/{firebase_uid}", response_model=EmotionChartResponse)
async def get_emotions_over_time(
        firebase_uid: str,
        days: int = 30,  # Tham số tùy chọn
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user_from_firebase)
):
    """
    Lấy dữ liệu cảm xúc theo thời gian

    Parameters:
    - firebase_uid: ID người dùng từ Firebase
    - days: Số ngày cần lấy dữ liệu (mặc định: 30)
    """
    try:
        # Xác thực người dùng
        if current_user.firebase_uid != firebase_uid:
            raise HTTPException(status_code=403, detail="Unauthorized access")

        # Tính toán khoảng thời gian
        end_date = date.today()
        start_date = end_date - timedelta(days=days)

        # Truy vấn dữ liệu
        notes = db.query(Note).filter(
            Note.user_id == current_user.id,
            Note.created_at >= start_date,
            Note.created_at <= end_date
        ).order_by(Note.created_at).all()

        # Xử lý aggregation
        daily_stats = defaultdict(lambda: defaultdict(int))
        for note in notes:
            note_date = note.created_at.date()
            for emotion in note.emotions or []:
                daily_stats[note_date][emotion] += 1

        # Điền đầy đủ các ngày
        chart_data = []
        current_date = start_date
        while current_date <= end_date:
            chart_data.append({
                "date": current_date,
                "emotion_counts": dict(daily_stats[current_date])
            })
            current_date += timedelta(days=1)

        return {"data": chart_data}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")