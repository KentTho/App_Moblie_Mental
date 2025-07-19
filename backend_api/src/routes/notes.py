import json # ✅ Import json module
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from src.db.database import get_db
from src.models.notes import Note
from src.schemas.note_schema import NoteCreate, NoteUpdate, NoteOut
from typing import List
from src.services.ai_emotion_service import analyze_emotions
from src.services.ai_sentiment_service import analyze_emotions_for_sentiment_field

router = APIRouter(prefix="/api/notes", tags=["Notes"])

@router.post("/", response_model=NoteOut)
async def create_note(note: NoteCreate, db: Session = Depends(get_db)):
    # Ensure content is not None before passing to AI analysis
    note_content_for_ai = note.content if note.content is not None else ""

    detected_sentiment_emotions = await analyze_emotions_for_sentiment_field(note_content_for_ai)
    detected_emotions = await analyze_emotions(note_content_for_ai)

    db_note = Note(
        user_id=note.user_id,
        title=note.title,
        content=note.content,
        # ✅ Convert List[dict] from Pydantic to JSON string for DB storage
        content_json=json.dumps(note.content_json) if note.content_json is not None else None,
        tags=note.tags,
        sentiment=", ".join(detected_sentiment_emotions) if detected_sentiment_emotions else None,
        emotions=detected_emotions
    )
    db.add(db_note)
    db.commit()
    db.refresh(db_note)
    return db_note

@router.get("/user/{user_id}", response_model=List[NoteOut])
def get_notes(user_id: str, db: Session = Depends(get_db)):
    return db.query(Note).filter(Note.user_id == user_id).order_by(Note.created_at.desc()).all()

@router.get("/{note_id}", response_model=NoteOut)
def get_note(note_id: str, db: Session = Depends(get_db)):
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
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
