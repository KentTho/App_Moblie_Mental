# main.py

from fastapi import FastAPI
from dotenv import load_dotenv
import sys
import os

from starlette.middleware.cors import CORSMiddleware

# Import route cho xác thực người dùng và nhật ký cảm xúc
# Import route
from src.routes import auth, notes, charts, suggestions, reminders, chatbot


# Import các models để SQLAlchemy nhận diện và tạo bảng
from src.models.user import User
from src.models.user_profile import UserProfile
from src.models.notes import Note
from src.models.reminder import Reminder # NEW

# Import cấu hình database (SQLAlchemy engine & Base)
from src.db.database import Base, engine

# Import hệ thống path để Python nhận biết đường dẫn tương đối


load_dotenv()


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
# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)
# -----------------------------------------
# Kết nối các router (endpoints) vào ứng dụng FastAPI

# 1. Route xác thực người dùng
app.include_router(auth.router)  # (Dòng gốc của bạn - vẫn giữ nguyên)
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])  # Có thể bỏ nếu trùng

# 2. Route quản lý nhật ký cảm xúc
app.include_router(notes.router)
app.include_router(notes.router, prefix="/api/notes", tags=["Notes"])

# 3. Route cho biểu đồ cảm xúc (NEW)
app.include_router(charts.router)
app.include_router(charts.router, prefix="/api/charts", tags=["Charts"])
# 4. Route cho gợi ý bài tập (NEW)
app.include_router(suggestions.router, prefix="/api/suggestions", tags=["Suggestions"])

# 5. Route cho nhắc nhở (NEW)
app.include_router(reminders.router, prefix="/api/reminders", tags=["Reminders"])

# 6. Route cho Chatbot AI (NEW)
app.include_router(chatbot.router, prefix="/api/chatbot", tags=["Chatbot"])