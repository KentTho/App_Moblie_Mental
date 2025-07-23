import json
import datetime # Import datetime for updated_at timestamp
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from src.db.database import get_db
from src.models import user
from src.models.notes import Note
from src.models.user import User
from src.schemas.note_schema import NoteCreate, NoteUpdate, NoteOut
from src.services.ai_emotion_service import analyze_emotions
from src.services.ai_sentiment_service import analyze_emotions_for_sentiment_field
from src.dependencies import get_current_user_from_firebase # Import the new dependency

router = APIRouter(prefix="/api/notes", tags=["Notes"])

@router.post("/", response_model=NoteOut)
async def create_note(
    note: NoteCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user_from_firebase)  # ✅ Truy user từ token
):
    # ✅ Không cần FE gửi user_id nữa, dùng current_user.id
    note_content_for_ai = note.content if note.content is not None else ""

    detected_sentiment_emotions = await analyze_emotions_for_sentiment_field(note_content_for_ai)
    detected_emotions = await analyze_emotions(note_content_for_ai)

    db_note = Note(
        user_id=current_user.id,  # ✅ Lấy ID từ User model trong DB (UUID)
        title=note.title,
        content=note.content,
        content_json=json.dumps(note.content_json) if note.content_json is not None else None,
        tags=note.tags,
        sentiment=", ".join(detected_sentiment_emotions) if detected_sentiment_emotions else None,
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
    # Optional: Add get_current_user_from_firebase dependency if you want to ensure the requesting user matches the UID
    # current_user: User = Depends(get_current_user_from_firebase)
):
    """
    Retrieves all notes for a specific user identified by their Firebase UID.
    """
    # Optional: Add authorization check if you uncomment the current_user dependency above
    # if current_user.firebase_uid != firebase_uid:
    #     raise HTTPException(
    #         status_code=status.HTTP_403_FORBIDDEN,
    #         detail="Not authorized to view notes for this user."
    #     )
    user = db.query(User).filter(User.firebase_uid == firebase_uid).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    notes = db.query(Note).filter(Note.user_id == user.id).order_by(Note.created_at.desc()).all()
    return notes

@router.get("/{note_id}", response_model=NoteOut)
def get_note(note_id: str, db: Session = Depends(get_db)):
    """
    Retrieves a single note by its ID.
    """
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Note not found")
    return note

@router.put("/{note_id}", response_model=NoteOut)
async def update_note(note_id: str, updated_note: NoteUpdate, db: Session = Depends(get_db)):
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")

    # Ensure content is not None before passing to AI analysis
    updated_note_content_for_ai = updated_note.content if updated_note.content is not None else ""

    detected_sentiment_emotions = await analyze_emotions_for_sentiment_field(updated_note_content_for_ai)
    detected_emotions = await analyze_emotions(updated_note_content_for_ai)

    note.title = updated_note.title
    note.content = updated_note.content
    # ✅ Convert List[dict] from Pydantic to JSON string for DB storage
    note.content_json = json.dumps(updated_note.content_json) if updated_note.content_json is not None else None
    note.tags = updated_note.tags
    note.sentiment = ", ".join(detected_sentiment_emotions) if detected_sentiment_emotions else None
    note.emotions = detected_emotions
    db.commit()
    db.refresh(note)
    return note

@router.delete("/{note_id}")
def delete_note(note_id: str, db: Session = Depends(get_db)):
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    db.delete(note)
    db.commit()
    return {"message": "Note deleted successfully"}

    db.delete(note)
    db.commit()
    return {"message": "Note deleted successfully"}
