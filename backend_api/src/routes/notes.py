from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from src.db.database import get_db  # ✅ Đúng
from src.models.notes import Note
from src.schemas.note_schema import NoteCreate, NoteUpdate, NoteOut
from typing import List

router = APIRouter(prefix="/api/notes", tags=["Notes"])

def detect_sentiment(content: str) -> str:
    content = content.lower()
    if "buồn" in content or "chán" in content:
        return "buồn"
    elif "vui" in content or "hạnh phúc" in content:
        return "vui"
    elif "lo" in content or "sợ" in content:
        return "lo âu"
    else:
        return "trung lập"

@router.post("/", response_model=NoteOut)
def create_note(note: NoteCreate, db: Session = Depends(get_db)):  # ✅ Sửa ở đây
    detected_sentiment = detect_sentiment(note.content)
    db_note = Note(
        user_id=note.user_id,
        title=note.title,
        content=note.content,
        content_json=note.content_json,  # ✅ thêm vào đây
        tags=note.tags,
        sentiment=detected_sentiment
    )
    db.add(db_note)
    db.commit()
    db.refresh(db_note)
    return db_note

@router.get("/user/{user_id}", response_model=List[NoteOut])
def get_notes(user_id: str, db: Session = Depends(get_db)):  # ✅ Sửa ở đây
    return db.query(Note).filter(Note.user_id == user_id).order_by(Note.created_at.desc()).all()

@router.get("/{note_id}", response_model=NoteOut)
def get_note(note_id: str, db: Session = Depends(get_db)):
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    return note

@router.put("/{note_id}", response_model=NoteOut)
def update_note(note_id: str, updated_note: NoteUpdate, db: Session = Depends(get_db)):
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")

    note.title = updated_note.title
    note.content = updated_note.content
    note.content_json = updated_note.content_json  # ✅ thêm vào đây
    note.tags = updated_note.tags
    note.sentiment = detect_sentiment(updated_note.content)
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
