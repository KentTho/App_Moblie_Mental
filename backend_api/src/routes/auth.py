from datetime import datetime, date
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel

from src.db.database import get_db
from src.models.notes import Note
from src.models.user import User
from src.models.user_profile import UserProfile
from src.services import user_service
from src.services.firebase import verify_firebase_token

router = APIRouter(prefix="/user", tags=["User"])

# --- SCHEMAS ---
class UserCreate(BaseModel):
    uid: str
    email: str
    password: str
    full_name: str


class UserFirebase(BaseModel):
    email: str
    uid: str
    full_name: Optional[str] = None


class UpdateVerified(BaseModel):
    uid: str
    is_verified: bool


class UpdateProfile(BaseModel):
    uid: str
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    phone: Optional[str] = None
    birthday: Optional[date] = None
    gender: Optional[str] = None


class UserResponse(BaseModel):
    id: str
    email: str
    full_name: Optional[str]
    avatar_url: Optional[str]
    role: str
    is_verified: bool
    birthday: Optional[date] = None
    gender: Optional[str] = None
    created_at: datetime
    updated_at: datetime


# --- REGISTER ---
@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.firebase_uid == user.uid).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = user_service.create_user(db, user.email, user.password, user.full_name)

    profile = UserProfile(
        user_id=new_user.id,
        full_name=user.full_name
    )
    db.add(profile)
    db.commit()

    return {"message": "User created successfully", "user_id": str(new_user.id)}


# --- SAVE FIREBASE USER ---
@router.post("/firebase")
def save_firebase_user(user: UserFirebase, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        return {"message": "User already exists", "user_id": str(existing_user.id)}

    new_user = User(
        email=user.email,
        firebase_uid=user.uid,
        full_name=user.full_name or "",
    )
    db.add(new_user)
    db.flush()

    profile = UserProfile(
        user_id=new_user.id,
        full_name=user.full_name or ""
    )
    db.add(profile)
    db.commit()

    return {"message": "User saved", "user_id": str(new_user.id)}


# --- GET USER BY FIREBASE UID ---
@router.get("/firebase/{uid}", response_model=UserResponse)
def get_user_by_firebase_uid(uid: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.firebase_uid == uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    profile = db.query(UserProfile).filter(UserProfile.user_id == user.id).first()

    return UserResponse(
        id=user.id,
        email=user.email,
        full_name=profile.full_name if profile else None,
        avatar_url=profile.avatar_url if profile else None,
        role=user.role or "user",
        is_verified=user.is_verified,
        birthday=profile.birthday if profile else None,
        gender=profile.gender if profile else None,
        created_at=user.created_at,
        updated_at=user.updated_at,
    )


# --- GET NOTES BY FIREBASE UID ---
@router.get("/firebase/{firebase_uid}/notes")
def get_notes_by_firebase_uid(firebase_uid: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.firebase_uid == firebase_uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    notes = db.query(Note).filter(Note.user_id == user.id).order_by(Note.created_at.desc()).all()
    return notes


# --- UPDATE PROFILE ---
@router.put("/update-profile")
def update_profile(payload: UpdateProfile, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.firebase_uid == payload.uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    profile = db.query(UserProfile).filter(UserProfile.user_id == user.id).first()
    if not profile:
        profile = UserProfile(user_id=user.id)
        db.add(profile)

    if payload.full_name is not None:
        profile.full_name = payload.full_name
    if payload.avatar_url is not None:
        profile.avatar_url = payload.avatar_url
    if payload.bio is not None:
        profile.bio = payload.bio
    if payload.phone is not None:
        profile.phone = payload.phone
    if payload.birthday is not None:
        profile.birthday = payload.birthday
    if payload.gender is not None:
        profile.gender = payload.gender

    db.commit()
    return {"message": "Profile updated"}


# --- DELETE USER BY FIREBASE UID ---
@router.delete("/delete/{uid}")
def delete_user(uid: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.firebase_uid == uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    db.delete(user)
    db.commit()
    return {"message": "User deleted"}


# --- UPDATE VERIFIED STATUS ---
@router.put("/update-verified")
def update_verified(
    payload: UpdateVerified,
    db: Session = Depends(get_db),
    firebase_user=Depends(verify_firebase_token),
):
    uid_from_token = firebase_user.get("uid")

    if not firebase_user.get("email_verified"):
        raise HTTPException(status_code=403, detail="Email is not verified on Firebase")

    user = db.query(User).filter(User.firebase_uid == uid_from_token).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.is_verified = payload.is_verified
    db.commit()
    return {"message": "Verification status updated"}
