from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from src.db.database import get_db
from src.services import user_service
from src.models import user as models
from pydantic import BaseModel

router = APIRouter(prefix="/user", tags=["User"])

# --- SCHEMA ---
class UserCreate(BaseModel):
    email: str
    password: str
    full_name: str

class UserFirebase(BaseModel):
    email: str
    uid: str
    full_name: str | None = None

class UpdateVerified(BaseModel):
    uid: str
    is_verified: bool

class UpdateProfile(BaseModel):
    uid: str
    full_name: str

# --- REGISTER ---
@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return user_service.create_user(db, user.email, user.password, user.full_name)

# --- SAVE FIREBASE USER ---
@router.post("/firebase")
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

# --- GET USER BY UID ---
@router.get("/firebase/{uid}")
def get_user_by_firebase_uid(uid: str, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.firebase_uid == uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return {
        "id": user.id,
        "email": user.email,
        "full_name": user.full_name,
        "role": user.role or "user",
        "is_verified": user.is_verified,
        "created_at": user.created_at,
        "updated_at": user.updated_at,
    }

# --- UPDATE VERIFIED STATUS ---
@router.put("/update-verified")
def update_verified(payload: UpdateVerified, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.firebase_uid == payload.uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.is_verified = payload.is_verified
    db.commit()
    return {"message": "Verification status updated"}

# --- UPDATE FULL NAME ---
@router.put("/update-profile")
def update_profile(payload: UpdateProfile, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.firebase_uid == payload.uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.full_name = payload.full_name
    db.commit()
    return {"message": "Profile updated"}

# --- DELETE USER ---
@router.delete("/delete/{uid}")
def delete_user(uid: str, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.firebase_uid == uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    db.delete(user)
    db.commit()
    return {"message": "User deleted"}
