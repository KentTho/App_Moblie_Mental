# Import thư viện cần thiết
import os
import json
from dotenv import load_dotenv     # Đọc file .env
from typing import List            # Định nghĩa kiểu trả về
from openai import OpenAI          # Thư viện OpenAI

# ⚠️ Bắt buộc load trước khi gọi getenv
load_dotenv()

# Tạo client OpenAI từ API Key trong file .env
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# Hàm phân tích cảm xúc chi tiết (trả về danh sách các cảm xúc)
async def analyze_emotions(text: str) -> List[str]:
    """
    Phân tích nhiều cảm xúc (joy, sadness, anger, calm, neutral, ...) từ nhật ký.
    Trả về danh sách các cảm xúc liên quan đến nội dung nhập vào.
    """

    if not text.strip():
        return []  # Nếu trống thì trả về danh sách rỗng

    try:
        # Gửi yêu cầu tới GPT-4o với yêu cầu trả về JSON
        response = await client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": f"""Analyze the primary emotions expressed in the following diary entry.
Return a JSON array of emotion labels like: ["joy", "sadness", "anger", "calm", "neutral"].

Diary Entry: "{text}"
"""}
            ],
            max_tokens=100,  # Đủ để chứa mảng JSON trả về
        )

        # Trích nội dung chuỗi JSON từ phản hồi
        content = response.choices[0].message.content.strip()

        # Phân tích chuỗi JSON thành danh sách
        emotions = json.loads(content)

        # Nếu hợp lệ, lọc bỏ trùng và trả về dạng chuẩn
        if isinstance(emotions, list):
            return sorted(list(set([
                e.lower() for e in emotions if isinstance(e, str) and e.strip()
            ])))
        else:
            return []

    except Exception as e:
        print(f"❌ Error during AI emotion analysis: {e}")
        return []
