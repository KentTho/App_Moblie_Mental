# src/utils/sentiment_emotion_utils.py

import re

# Từ khóa mẫu theo từng cảm xúc
SENTIMENT_KEYWORDS = {
    "sad": ["mệt", "chán", "buồn", "khó chịu", "áp lực", "stress"],
    "happy": ["vui", "tuyệt", "hạnh phúc", "yêu đời"],
    "angry": ["giận", "tức", "bực", "cay cú"],
    "anxious": ["lo", "hồi hộp", "băn khoăn", "sợ"],
}

# Câu trả lời mẫu
RESPONSE_MAP = {
    "sad": "Tôi hiểu điều đó. Bạn muốn chia sẻ điều gì đang làm bạn lo lắng không?",
    "happy": "Thật tuyệt khi bạn đang cảm thấy tích cực! Bạn muốn kể thêm chứ?",
    "angry": "Tôi hiểu cảm giác đó có thể rất khó chịu. Hãy thử hít thở sâu một chút nhé.",
    "anxious": "Bạn đang lo lắng về điều gì vậy? Mình cùng nhau tìm cách giải tỏa nhé.",
    "neutral": "Cảm ơn bạn đã chia sẻ. Mình ở đây nếu bạn cần tâm sự thêm.",
}

def analyze_sentiment(text: str) -> str:
    text = text.lower()
    for sentiment, keywords in SENTIMENT_KEYWORDS.items():
        for kw in keywords:
            if re.search(rf"\b{re.escape(kw)}\b", text):
                return sentiment
    return "neutral"

def get_emotion_response(sentiment: str) -> str:
    return RESPONSE_MAP.get(sentiment, RESPONSE_MAP["neutral"])
