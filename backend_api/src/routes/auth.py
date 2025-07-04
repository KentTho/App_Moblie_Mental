from datetime import datetime, date

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from src.db.database import get_db
from src.services import user_service
from src.models.user import User
from src.models.user_profile import UserProfile
from pydantic import BaseModel
from typing import Optional
from uuid import UUID
from firebase_admin import auth
from fastapi import Body

from src.services.firebase import verify_firebase_token

# Nếu bạn đặt verify_firebase_token ở file khác, cập nhật đúng đường dẫn
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
    birthday: Optional[date] = None       # 🟢 Thêm ngày sinh
    gender: Optional[str] = None

class UserResponse(BaseModel):
    id: UUID  # ✅ Đúng kiểu
    email: str
    full_name: Optional[str]
    avatar_url: Optional[str]
    role: str
    is_verified: bool
    birthday: Optional[date] = None  # 👈 Thêm
    gender: Optional[str] = None
    created_at: datetime
    updated_at: datetime


# --- REGISTER ---
@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.firebase_uid == user.uid).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Create user
    new_user = user_service.create_user(db, user.email, user.password, user.full_name)

    # Create profile
    profile = UserProfile(
        user_id=new_user.id,
        full_name=user.full_name
    )
    db.add(profile)
    db.commit()

    return {"message": "User created successfully", "user_id": new_user.id}


# --- SAVE FIREBASE USER ---
@router.post("/firebase")
def save_firebase_user(user: UserFirebase, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        return {"message": "User already exists"}

    # Create user
    new_user = User(
        email=user.email,
        firebase_uid=user.uid,
        full_name=user.full_name or "",
    )
    db.add(new_user)
    db.flush()  # Get the ID without committing

    # Create profile
    profile = UserProfile(
        user_id=new_user.id,
        full_name=user.full_name or ""
    )
    db.add(profile)
    db.commit()

    return {"message": "User saved"}


# --- GET USER BY UID ---
@router.get("/firebase/{uid}", response_model=UserResponse)
def get_user_by_firebase_uid(uid: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.firebase_uid == uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Get profile data
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
        created_at=user.created_at.isoformat(),
        updated_at=user.updated_at.isoformat(),
    )



# --- UPDATE PROFILE ---
@router.put("/update-profile")
def update_profile(payload: UpdateProfile, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.firebase_uid == payload.uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Get or create profile
    profile = db.query(UserProfile).filter(UserProfile.user_id == user.id).first()
    if not profile:
        profile = UserProfile(user_id=user.id)
        db.add(profile)

    # Update profile fields
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


# --- DELETE USER ---
@router.delete("/delete/{uid}")
def delete_user(uid: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.firebase_uid == uid).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Profile will be deleted automatically due to CASCADE
    db.delete(user)
    db.commit()
    return {"message": "User deleted"}


# --- UPDATE VERIFIED STATUS ---
# --- UPDATE VERIFIED STATUS ---
@router.put("/update-verified")
def update_verified(
    payload: UpdateVerified,
    db: Session = Depends(get_db),
    firebase_user=Depends(verify_firebase_token),  # ✅ Middleware kiểm tra Firebase token
):
    # ✅ Dùng uid từ token thay vì từ payload để tránh giả mạo
    uid_from_token = firebase_user.get("uid")

    # ✅ Kiểm tra email đã xác minh chưa
    if not firebase_user.get("email_verified"):
        raise HTTPException(status_code=403, detail="Email is not verified on Firebase")

    user = db.query(User).filter(User.firebase_uid == uid_from_token).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.is_verified = payload.is_verified
    db.commit()
    return {"message": "Verification status updated"}


