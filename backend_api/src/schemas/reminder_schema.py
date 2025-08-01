# src/schemas/reminder_schema.py
from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from uuid import UUID

class ReminderBase(BaseModel):
    message: str
    scheduled_time: datetime
    is_active: Optional[bool] = True

class ReminderCreate(ReminderBase):
    # user_id: str # User ID is required for creation
    message: Optional[str] = None
    scheduled_time: Optional[datetime] = None
    is_active: Optional[bool] = None

class ReminderUpdate(ReminderBase):
    # All fields are optional for update
    message: Optional[str] = None
    scheduled_time: Optional[datetime] = None
    is_active: Optional[bool] = None

class ReminderOut(ReminderBase):
    id: UUID
    user_id: str
    created_at: datetime
    updated_at: datetime

    model_config = {
        "from_attributes": True
    }
