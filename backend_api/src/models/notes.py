from sqlalchemy.dialects.postgresql import JSONB  # ✅ Import thêm
from sqlalchemy.dialects.postgresql import UUID
from uuid import uuid4
from datetime import datetime
from src.db.database import Base
from sqlalchemy import Column, String, ARRAY, ForeignKey, DateTime
class Note(Base):
    __tablename__ = "notes"

    id = Column(String, primary_key=True, default=lambda: str(uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String)
    content = Column(String, nullable=False)
    content_json = Column(JSONB, nullable=True)  # ✅ Thêm trường mới
    tags = Column(ARRAY(String), default=[])
    sentiment = Column(String)  # kết quả phân tích cảm xúc
    emotions = Column(ARRAY(String), nullable=True, default=[])  # ✅ NEW: Add emotions column
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
