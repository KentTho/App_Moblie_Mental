from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from src.db.database import Base
from src.models.notes import Note
from src.schemas.note_schema import NoteCreate, NoteUpdate, NoteOut
from typing import List

router = APIRouter(prefix="/notes", tags=["Notes"])

def detect_sentiment(content: str) -> str:
    # ⚠️ Tạm thời mô phỏng logic AI đơn giản
    content = content.lower()
    if "buồn" in content or "chán" in content:
        return "buồn"
    elif "vui" in content or "hạnh phúc" in content:
        return "vui"
    elif "lo" in content or "sợ" in content:
        return "lo âu"
    else:
        return "trung lập"



# POST - Tạo nhật ký (kèm phân tích cảm xúc)
@router.post("/", response_model=NoteOut)
def create_note(note: NoteCreate, db: Session = Depends(Base)):
    # TODO: Gọi AI phân tích cảm xúc từ note.content
    detected_sentiment = detect_sentiment(note.content)  # → ví dụ: "vui", "buồn"

    db_note = Note(
        user_id=note.user_id,
        title=note.title,
        content=note.content,
        tags=note.tags,
        sentiment=detected_sentiment
    )
    db.add(db_note)
    db.commit()
    db.refresh(db_note)
    return db_note

# GET - Lấy danh sách nhật ký của người dùng
@router.get("/user/{user_id}", response_model=List[NoteOut])
def get_notes(user_id: str, db: Session = Depends(Base)):
    return db.query(Note).filter(Note.user_id == user_id).order_by(Note.created_at.desc()).all()

# GET - Lấy 1 note cụ thể
@router.get("/{note_id}", response_model=NoteOut)
def get_note(note_id: str, db: Session = Depends(Base)):
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    return note

# PUT - Cập nhật note
@router.put("/{note_id}", response_model=NoteOut)
def update_note(note_id: str, updated_note: NoteUpdate, db: Session = Depends(Base)):
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")

    note.title = updated_note.title
    note.content = updated_note.content
    note.tags = updated_note.tags
    # Gọi lại AI để phân tích lại cảm xúc nếu cần
    note.sentiment = detect_sentiment(updated_note.content)
    db.commit()
    db.refresh(note)
    return note

# DELETE - Xóa note
@router.delete("/{note_id}")
def delete_note(note_id: str, db: Session = Depends(Base)):
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    db.delete(note)
    db.commit()
    return {"message": "Note deleted successfully"}
