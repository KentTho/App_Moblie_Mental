from typing import List, Dict, Any
from transformers import pipeline

# Define the emotions that the frontend is prepared to display.
FRONTEND_EMOTIONS = {
    "joy", "sadness", "anger", "fear", "surprise", "disgust",
    "calm", "excitement", "neutral", "enjoyment"
}

# ✅ Load Hugging Face emotion model once globally
try:
    sentiment_classifier = pipeline(
        "text-classification",
        model="visolex/bartpho-emotion",
        return_all_scores=True
    )
    print("✅ Vietnamese Sentiment/Emotion model loaded.")
except Exception as e:
    sentiment_classifier = None
    print(f"❌ Failed to load Vietnamese Sentiment/Emotion model: {e}")
    print("Please ensure 'torch' or 'tensorflow' and 'transformers' are installed.")


async def analyze_emotions_for_sentiment_field(text: str) -> List[str]:
    """
    Phân tích các cảm xúc chi tiết từ văn bản, phù hợp với các nhãn cảm xúc của frontend.
    Trả về danh sách các cảm xúc liên quan đến nội dung nhập vào.
    """
    if not text.strip() or not sentiment_classifier:
        print("⚠️ No input text or sentiment model not loaded.")
        return []
    try:
        prediction: List[List[Dict[str, Any]]] = sentiment_classifier(text)
        results = prediction[0]

        detected_emotions = [
            res["label"].lower()
            for res in results
            if res["score"] > 0.3 and res["label"].lower() in FRONTEND_EMOTIONS
        ]

        # Fallback nếu không có cảm xúc nào vượt ngưỡng
        if not detected_emotions:
            top = max(results, key=lambda x: x["score"])
            if top["label"].lower() in FRONTEND_EMOTIONS:
                detected_emotions = [top["label"].lower()]

        print(f"✅ Final multi-class emotions: {detected_emotions}")
        return sorted(detected_emotions)

    except Exception as e:
        print(f"❌ Error during emotion analysis for sentiment field: {e}")
        return []
