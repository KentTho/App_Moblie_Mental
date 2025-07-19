import os
import json
from dotenv import load_dotenv
from typing import List
from transformers import pipeline

# ⚠️ Load biến môi trường
load_dotenv()

# Các cảm xúc mà frontend có thể hiển thị
FRONTEND_EMOTIONS = {
    "joy", "sadness", "anger", "fear", "surprise", "disgust",
    "calm", "excitement", "neutral"
}

# ✅ Mô hình mới: visolex/bartpho-emotion
try:
    local_emotion_classifier = pipeline(
        "text-classification",
        model="visolex/bartpho-emotion",
        return_all_scores=True  # rất quan trọng
    )
    print("✅ Hugging Face Vietnamese emotion model loaded successfully.")
except Exception as e:
    local_emotion_classifier = None
    print(f"❌ Failed to load Hugging Face Vietnamese emotion model: {e}")
    print("Please ensure 'torch' or 'tensorflow' and 'transformers' are installed.")


async def analyze_emotions(text: str) -> List[str]:
    """
    Phân tích nhiều cảm xúc (joy, sadness, anger, fear, surprise, disgust, ...) từ nhật ký.
    Trả về danh sách các cảm xúc phù hợp với nội dung.
    """
    if not text.strip() or not local_emotion_classifier:
        print("⚠️ No input text or model not loaded.")
        return []

    try:
        results = local_emotion_classifier(text)[0]  # Trả về danh sách label-score
        emotions = [
            res['label'].lower()
            for res in results
            if res['score'] > 0.5 and res['label'].lower() in FRONTEND_EMOTIONS
        ]

        # Nếu không có cảm xúc > 0.5, chọn cảm xúc mạnh nhất
        if not emotions and results:
            top = max(results, key=lambda x: x['score'])
            emotions = [top['label'].lower()] if top['label'].lower() in FRONTEND_EMOTIONS else []

        print(f"✅ Emotions analyzed using Bartpho model: {emotions}")
        return sorted(set(emotions))

    except Exception as e:
        print(f"❌ Error during local emotion analysis: {e}")
        return []
