from sqlalchemy import Column, String, Date, ForeignKey, DateTime
from sqlalchemy.dialects.postgresql import UUID
import uuid
from datetime import datetime
from src.db.database import Base




class UserProfile(Base):
    __tablename__ = "user_profiles"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    full_name = Column(String(100))
    gender = Column(String(10))
    birthday = Column(Date)
    avatar_url = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
