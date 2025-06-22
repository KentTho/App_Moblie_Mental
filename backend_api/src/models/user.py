from sqlalchemy import Column, String, Integer
from src.db.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    password = Column(String, nullable=True)
    full_name = Column(String)
    firebase_uid = Column(String, nullable=True)
