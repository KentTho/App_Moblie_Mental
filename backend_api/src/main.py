# main.py

from fastapi import FastAPI

# Import route cho xác thực người dùng và nhật ký cảm xúc
from src.routes import auth
from src.routes import note_router

# Import các models để SQLAlchemy nhận diện và tạo bảng
from src.models.user import User
from src.models.user_profile import UserProfile
from src.models.notes import Note

# Import cấu hình database (SQLAlchemy engine & Base)
from src.db.database import Base, engine

# Import hệ thống path để Python nhận biết đường dẫn tương đối
import sys
import os

# Thêm đường dẫn hiện tại vào hệ thống tìm kiếm module của Python
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# -----------------------------------------
# Tạo bảng tự động nếu chưa tồn tại trong cơ sở dữ liệu
Base.metadata.create_all(bind=engine)

# -----------------------------------------
# Khởi tạo ứng dụng FastAPI
app = FastAPI(
    title="Mental Health API",
    description="API cho ứng dụng sức khỏe tinh thần (Ghi nhật ký, xác thực, phân tích cảm xúc...)",
    version="1.0.0"
)

# -----------------------------------------
# Kết nối các router (endpoints) vào ứng dụng FastAPI

# 1. Route xác thực người dùng
app.include_router(auth.router)  # (Dòng gốc của bạn - vẫn giữ nguyên)
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])  # Có thể bỏ nếu trùng

# 2. Route quản lý nhật ký cảm xúc
app.include_router(note_router.router, prefix="/api/notes", tags=["Notes"])
