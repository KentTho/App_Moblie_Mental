import os
from typing import List, Dict, Any, Optional, Union, Tuple
from dotenv import load_dotenv
from transformers import pipeline

# Load biến môi trường nếu cần
load_dotenv()

# Các cảm xúc mà frontend có thể hiển thị
FRONTEND_EMOTIONS = {
    "joy", "sadness", "anger", "fear", "surprise", "disgust",
    "calm", "excitement", "neutral", "enjoyment"
}

# ✅ Load mô hình phân tích cảm xúc từ Hugging Face
try:
    emotion_classifier = pipeline(
        "text-classification",
        model="visolex/bartpho-emotion",
        return_all_scores=True,
        top_k=2,
        truncation=True,
        max_length=256,
    )
    print("✅ Emotion model loaded successfully.")
except Exception as e:
    emotion_classifier = None
    print(f"❌ Failed to load emotion model: {e}")
    print("Please ensure required libraries are installed.")


async def analyze_emotions(text: str) -> List[str]:
    """
    Phân tích cảm xúc từ văn bản với xử lý ngữ cảnh thông minh
    Trả về danh sách cảm xúc đã được chuẩn hóa
    """
    if not text.strip() or not emotion_classifier:
        return ["neutral"]

    try:
        # 1. Tiền xử lý ngữ cảnh đặc biệt
        text_lower = text.lower()

        # Từ khóa đặc trưng cho từng cảm xúc
        context_keywords = {
            "anger": ["tức điên", "bực bội", "phẫn nộ", "điên lên", "bất công", "tức giận"],
            "joy": ["vui sướng", "hạnh phúc", "phấn khởi", "tuyệt vời", "thích thú"],
            "fear": ["sợ hãi", "hoảng loạn", "khiếp sợ", "run sợ"],
            "calm": ["yên bình", "tĩnh lặng", "bình yên", "thư thái"],
            "disgust": ["kinh tởm", "ghê tởm", "buồn nôn"]
        }

        # Kiểm tra ngữ cảnh ưu tiên trước
        for emotion, keywords in context_keywords.items():
            if any(keyword in text_lower for keyword in keywords):
                return [emotion]

        # 2. Phân tích bằng model
        prediction = emotion_classifier(text)
        print(f"DEBUG: Raw prediction: {prediction}")

        results = prediction[0] if isinstance(prediction, list) and prediction else []
        emotions = []

        for res in results:
            if not isinstance(res, dict):
                continue

            label = str(res.get('label', '')).strip().lower()
            score = float(res.get('score', 0))

            # 3. Ánh xạ thông minh với ngữ cảnh
            mapped = map_emotion_label(label, text_lower)

            # 4. Ngưỡng điểm linh hoạt
            threshold = 0.4  # Ngưỡng chung
            if mapped in ["anger", "joy"]:  # Ưu tiên cảm xúc mạnh
                threshold = 0.3
            elif mapped == "neutral":
                threshold = 0.6  # Yêu cầu cao hơn cho neutral

            if score >= threshold:
                emotions.append(mapped)

        # 5. Hậu xử lý
        if not emotions:
            return ["neutral"]

        # Ưu tiên cảm xúc mạnh hơn nếu có nhiều cảm xúc
        priority_emotions = ["anger", "fear", "joy", "sadness"]
        for emo in priority_emotions:
            if emo in emotions:
                return [emo]

        return list(dict.fromkeys(emotions))[:2]  # Giới hạn tối đa 2 cảm xúc

    except Exception as e:
        print(f"❌ Emotion analysis failed: {str(e)}")
        # Fallback thông minh dựa trên từ khóa
        if any(word in text_lower for word in context_keywords["anger"]):
            return ["anger"]
        return ["neutral"]


def map_emotion_label(raw_label: str, context_text: str = "") -> str:
    """
    Ánh xạ nhãn cảm xúc thông minh với xử lý ngữ cảnh
    """
    # 1. Chuẩn hóa nhãn đầu vào
    label = raw_label.strip().lower()

    # 2. Mapping mở rộng
    emotion_map = {
        # Tiếng Việt
        "tich_cuc": "joy",
        "tieu_cuc": "sadness",
        "trung_tinh": "neutral",
        "vui": "joy",
        "buồn": "sadness",
        "tức giận": "anger",
        "sợ hãi": "fear",

        # Tiếng Anh
        "enjoyment": "joy",
        "happiness": "joy",
        "joy": "joy",
        "sadness": "sadness",
        "anger": "anger",
        "fear": "fear",
        "disgust": "disgust",
        "surprise": "surprise",
        "calm": "calm",
        "excitement": "joy",
        "other": "neutral",

        # Mặc định
        "unknown": "neutral"
    }

    # 3. Xử lý đặc biệt cho một số nhãn
    if label == "sadness" and any(word in context_text for word in ["yên bình", "tĩnh lặng"]):
        return "calm"

    if label == "fear" and "tức" in context_text:
        return "anger"

    # 4. Trả về kết quả đã ánh xạ
    return emotion_map.get(label, "neutral")