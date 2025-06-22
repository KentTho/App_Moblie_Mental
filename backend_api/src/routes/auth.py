from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from src.db.database import SessionLocal
from src.services import user_service
from src.models import user as models
from pydantic import BaseModel

router = APIRouter()

class UserCreate(BaseModel):
    email: str
    password: str
    full_name: str

class UserFirebase(BaseModel):  # 👈 THÊM CLASS NÀY
    email: str
    uid: str
    full_name: str | None = None

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return user_service.create_user(db, user.email, user.password, user.full_name)

@router.post("/firebase-user")
def save_firebase_user(user: UserFirebase, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if db_user:
        return {"message": "User already exists"}

    new_user = models.User(
        email=user.email,
        firebase_uid=user.uid,
        full_name=user.full_name or "",
    )
    db.add(new_user)
    db.commit()
    return {"message": "User saved"}
