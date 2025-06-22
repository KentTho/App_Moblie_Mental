from sqlalchemy import Column, String, Text, Boolean, DateTime, Enum
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
import uuid
from src.db.database import Base

import enum

class RoleEnum(str, enum.Enum):
    user = 'user'
    admin = 'admin'


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    full_name = Column(String)
    firebase_uid = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)