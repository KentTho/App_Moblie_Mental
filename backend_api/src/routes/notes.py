import json
import datetime  # Sử dụng cho cập nhật thời gian
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

# Import các thành phần cần thiết từ thư mục nội bộ
from src.db.database import get_db
from src.models.notes import Note
from src.models.user import User
from src.schemas.note_schema import NoteCreate, NoteUpdate, NoteOut
from src.services.ai_emotion_service import analyze_emotions
from src.dependencies import get_current_user_from_firebase  # Dependency xác thực từ Firebase

# Tạo router với prefix "/api/notes"
router = APIRouter(prefix="/api/notes", tags=["Notes"])


@router.post("/", response_model=NoteOut)
async def create_note(
        note: NoteCreate,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user_from_firebase)
):
    note_content_for_ai = note.content if note.content is not None else ""

    detected_emotions = await analyze_emotions(note_content_for_ai)

    # Đảm bảo emotions không null
    if not detected_emotions:
        detected_emotions = ["neutral"]

    db_note = Note(
        user_id=current_user.id,
        title=note.title,
        content=note.content,
        content_json=json.dumps(note.content_json) if note.content_json is not None else None,
        tags=note.tags,
        sentiment=", ".join(detected_emotions),
        emotions=detected_emotions
    )
    db.add(db_note)
    db.commit()
    db.refresh(db_note)
    return db_note

@router.get("/user/{firebase_uid}", response_model=List[NoteOut])
def get_notes_by_firebase_uid_route(
    firebase_uid: str,
    db: Session = Depends(get_db),
    # current_user: User = Depends(get_current_user_from_firebase)  # Mở nếu cần xác thực
):
    """
    Lấy tất cả ghi chú của người dùng dựa vào Firebase UID.
    """
    user = db.query(User).filter(User.firebase_uid == firebase_uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    notes = db.query(Note).filter(Note.user_id == user.id).order_by(Note.created_at.desc()).all()
    return notes


@router.get("/{note_id}", response_model=NoteOut)
def get_note(note_id: str, db: Session = Depends(get_db)):
    """
    Lấy thông tin chi tiết của một ghi chú theo ID.
    """
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    return note


@router.put("/{note_id}", response_model=NoteOut)
async def update_note(
    note_id: str,
    updated_note: NoteUpdate,
    db: Session = Depends(get_db)
):
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")

    updated_note_content_for_ai = updated_note.content or ""

    # Xử lý tương tự như create_note
    emotion_results = await analyze_emotions(updated_note_content_for_ai)
    detected_emotions = []
    if emotion_results:
        emotions_iterable = list(emotion_results) if isinstance(emotion_results, set) else emotion_results
        for e in emotions_iterable:
            if isinstance(e, (tuple, list)) and len(e) > 0:
                detected_emotions.append(str(e[0]))
            elif isinstance(e, str):
                detected_emotions.append(e)

    note.title = updated_note.title
    note.content = updated_note.content
    note.content_json = json.dumps(updated_note.content_json) if updated_note.content_json is not None else None
    note.tags = updated_note.tags
    note.sentiment = ", ".join(detected_emotions) if detected_emotions else None
    note.emotions = detected_emotions

    db.commit()
    db.refresh(note)
    return note

@router.delete("/{note_id}")
def delete_note(note_id: str, db: Session = Depends(get_db)):
    """
    Xóa ghi chú theo ID.
    """
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    db.delete(note)
    db.commit()
    return {"message": "Note deleted successfully"}


def determine_sentiment(emotions: List[str]) -> Optional[str]:
    """
    Phân loại cảm xúc tổng thể dựa trên danh sách cảm xúc chi tiết.

    - Ưu tiên cảm xúc mạnh như joy, anger, sadness.
    - Nếu không có, phân nhóm theo tích cực / tiêu cực / trung tính.
    """
    if not emotions:
        return None

    positive_emotions = {"joy", "surprise", "excitement", "enjoyment", "calm"}
    negative_emotions = {"sadness", "anger", "fear", "disgust"}

    if "joy" in emotions:
        return "Vui vẻ"
    elif "anger" in emotions:
        return "Tức giận"
    elif "sadness" in emotions:
        return "Buồn bã"

    if any(e in positive_emotions for e in emotions):
        return "Tích cực"
    elif any(e in negative_emotions for e in emotions):
        return "Tiêu cực"
    return "Trung tính"
