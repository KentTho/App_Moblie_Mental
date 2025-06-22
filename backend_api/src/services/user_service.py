from passlib.context import CryptContext
from sqlalchemy.orm import Session
from src.models import user as models

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    return pwd_context.hash(password)

def create_user(db: Session, email: str, password: str, full_name: str = ""):
    hashed_password = get_password_hash(password)
    db_user = models.User(email=email, hashed_password=hashed_password, full_name=full_name)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user
