from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase

# Đường dẫn PostgreSQL (thay đổi user/pass/db nếu cần)
DATABASE_URL = "postgresql://admin:admin123@localhost:5432/mental_health_app"

# Kết nối đến PostgreSQL
engine = create_engine(DATABASE_URL)

# Tạo session để giao tiếp với DB
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Định nghĩa lớp cơ sở cho ORM models
class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
