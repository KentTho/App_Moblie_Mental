# src/routes/reminders.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from src.db.database import get_db
from src.dependencies import get_current_user_from_firebase
from src.models import User
from src.models.reminder import Reminder
from src.schemas.reminder_schema import ReminderCreate, ReminderUpdate, ReminderOut
from typing import List
from uuid import UUID

router = APIRouter(prefix="/api/reminders", tags=["Reminders"])

@router.post("/", response_model=ReminderOut, status_code=status.HTTP_201_CREATED)
def create_reminder(reminder: ReminderCreate, db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user_from_firebase)):
    """
    Creates a new journaling reminder for a user.
    """
    db_reminder = Reminder(**reminder.model_dump())
    #.user_id = current_user.id
    db_reminder=Reminder(
        user_id=current_user.id,
        message=reminder.message,
        scheduled_time=reminder.scheduled_time,
        is_active=reminder.is_active
    )

    db.add(db_reminder)
    db.commit()
    db.refresh(db_reminder)
    return db_reminder

@router.get("/user/{firebase_uid}", response_model=List[ReminderOut])
def get_user_reminders(firebase_uid: str, db: Session = Depends(get_db)):
    """
    Retrieves all reminders for a specific user.
    """
    reminders = db.query(Reminder).filter(User.firebase_uid == firebase_uid).order_by(Reminder.scheduled_time).all()
    if reminders is None:
        raise HTTPException(status_code=404, detail="Reminders not found")
    return reminders

@router.get("/{reminder_id}", response_model=ReminderOut)
def get_reminder(reminder_id: UUID, db: Session = Depends(get_db)):
    """
    Retrieves a single reminder by its ID.
    """
    reminder = db.query(Reminder).filter(Reminder.id == reminder_id).first()
    if not reminder:
        raise HTTPException(status_code=404, detail="Reminder not found")
    return reminder

@router.put("/{reminder_id}", response_model=ReminderOut)
def update_reminder(reminder_id: UUID, updated_reminder: ReminderUpdate, db: Session = Depends(get_db)):
    """
    Updates an existing reminder.
    """
    db_reminder = db.query(Reminder).filter(Reminder.id == reminder_id).first()
    if not db_reminder:
        raise HTTPException(status_code=404, detail="Reminder not found")

    for key, value in updated_reminder.model_dump(exclude_unset=True).items():
        setattr(db_reminder, key, value)

    db.commit()
    db.refresh(db_reminder)
    return db_reminder

@router.delete("/{reminder_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_reminder(reminder_id: UUID, db: Session = Depends(get_db)):
    """
    Deletes a reminder by its ID.
    """
    db_reminder = db.query(Reminder).filter(Reminder.id == reminder_id).first()
    if not db_reminder:
        raise HTTPException(status_code=404, detail="Reminder not found")

    db.delete(db_reminder)
    db.commit()
    return {"message": "Reminder deleted successfully"}
