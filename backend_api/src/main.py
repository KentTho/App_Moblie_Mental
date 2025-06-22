from fastapi import FastAPI
from src.routes import auth
from src.db.database import Base, engine

# Tạo bảng từ models nếu chưa tồn tại
Base.metadata.create_all(bind=engine)

# Khởi tạo ứng dụng FastAPI
app = FastAPI()

# Kết nối route auth với prefix
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
