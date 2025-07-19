from typing import List
from transformers import pipeline  # ✅ Hugging Face pipeline

# ✅ Load Hugging Face model once globally to avoid re-loading on every call
try:
    # This model is typically for emotion classification (e.g., joy, sadness, anger)
    # The 'sentiment-analysis' pipeline type is often used for emotion classification too.
    local_emotion_classifier = pipeline(
        'sentiment-analysis', # This pipeline type works for emotion classification models
        model="j-hartmann/emotion-english-distilroberta-base"
    )
    print("✅ Hugging Face emotion model loaded successfully.")
except Exception as e:
    local_emotion_classifier = None
    print(f"❌ Failed to load Hugging Face emotion model: {e}")
    print("Please ensure 'torch' or 'tensorflow' and 'transformers' are installed.")


async def analyze_emotions(text: str) -> List[str]:
    """
    Phân tích nhiều cảm xúc (joy, sadness, anger, calm, neutral, ...) từ nhật ký.
    Trả về danh sách các cảm xúc liên quan đến nội dung nhập vào.
    """
    if not text.strip():
        return []

    if not local_emotion_classifier:
        print("⚠️ Local Hugging Face emotion model not loaded. No emotion analysis performed.")
        return []

    try:
        # The pipeline call is synchronous. If this function is called from an async FastAPI endpoint,
        # it will block the event loop. For CPU-bound tasks like model inference,
        # consider running this in a separate thread pool if concurrency is high.
        results = local_emotion_classifier(text)

        # Extract labels and filter by score.
        # The 'j-hartmann/emotion-english-distilroberta-base' model typically outputs
        # labels like 'joy', 'sadness', 'anger', 'fear', 'surprise', 'disgust'.
        # It might not directly output 'calm' or 'neutral' as distinct labels.
        emotions = sorted(list(set([
            res['label'].lower() for res in results if res['score'] > 0.5
        ])))

        # Fallback: if no emotions meet the threshold, take the top-scoring one.
        if not emotions and results:
            emotions = [results[0]['label'].lower()]

        print("✅ Emotions analyzed using local Hugging Face model.")
        return emotions

    except Exception as e:
        print(f"❌ Error during local Hugging Face emotion analysis: {e}")
        return []
