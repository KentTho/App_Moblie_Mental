from passlib.context import CryptContext
from sqlalchemy.orm import Session
from src.models.user import User
import uuid
from datetime import datetime


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    return pwd_context.hash(password)

def create_user_if_not_exists(db: Session, firebase_user, full_name):
    user = db.query(User).filter(User.email == firebase_user["email"]).first()
    if not user:
        user = User(
            id=str(uuid.uuid4()),
            email=firebase_user["email"].split("@")[0],
            full_name=full_name,
            role="user",
            is_verified=True,
            created_at=datetime.utcnow()
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    return user
