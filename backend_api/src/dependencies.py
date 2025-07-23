import uuid
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session

from src.db.database import get_db
from src.models.user import User
from src.services.firebase import verify_firebase_token

async def get_current_user_from_firebase(
    db: Session = Depends(get_db),
    firebase_user_data: dict = Depends(verify_firebase_token)
) -> User:
    """
    Dependency to get or create a user in the database based on Firebase authentication.
    Returns the internal User object from the database.
    """
    firebase_uid = firebase_user_data.get("uid")
    if not firebase_uid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Firebase token did not contain a UID."
        )
    print("🔥 Firebase user data:", firebase_user_data)

    user = db.query(User).filter(User.firebase_uid == firebase_uid).first()

    if not user:
        # User does not exist in our database, create a new entry
        new_user_id = str(uuid.uuid4()) # Generate a UUID for the new user
        new_user = User(
            id=new_user_id,
            firebase_uid=firebase_uid,
            email=firebase_user_data.get("email"), # Assuming email is provided by Firebase
            # Add other default user fields here if necessary, e.g., created_at
        )
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        user = new_user
        print(f"Created new user with ID: {user.id} and Firebase UID: {user.firebase_uid}")
    else:
        print(f"Found existing user with ID: {user.id} and Firebase UID: {user.firebase_uid}")

    return user
