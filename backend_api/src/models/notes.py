from sqlalchemy import Column, String, DateTime, ARRAY
from uuid import uuid4
from datetime import datetime
from src.db.database import Base

class Note(Base):
    __tablename__ = "notes"

    id = Column(String, primary_key=True, default=lambda: str(uuid4()))
    user_id = Column(String, nullable=False, index=True)
    title = Column(String)
    content = Column(String, nullable=False)
    tags = Column(ARRAY(String), default=[])
    sentiment = Column(String)  # kết quả phân tích cảm xúc
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
