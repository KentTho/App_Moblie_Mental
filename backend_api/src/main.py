from fastapi import FastAPI
from src.routes import auth
from src.models.user import User
from src.models.user_profile import UserProfile

from src.db.database import Base, engine



# import các models để SQLAlchemy nhận biết và tạo bảng



import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))



# Tạo bảng từ models nếu chưa tồn tại
Base.metadata.create_all(bind=engine)

# Khởi tạo ứng dụng FastAPI
app = FastAPI()

# Kết nối route auth với prefix
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
