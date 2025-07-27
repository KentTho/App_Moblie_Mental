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
        print(f"DEBUG: Raw sentiment prediction: {prediction}") # DEBUG: Print raw prediction
        results = prediction[0] if isinstance(prediction, list) and prediction and isinstance(prediction[0], list) else []

        detected_emotions = set()
        for res in results:
            label = res['label'].lower()
            score = res['score']

            mapped_label = None
            if label == 'tich_cuc':
                if 'joy' in FRONTEND_EMOTIONS:
                    mapped_label = 'joy'
                elif 'excitement' in FRONTEND_EMOTIONS:
                    mapped_label = 'excitement'
            elif label == 'tieu_cuc':
                if 'sadness' in FRONTEND_EMOTIONS:
                    mapped_label = 'sadness'
                elif 'anger' in FRONTEND_EMOTIONS:
                    mapped_label = 'anger'
                elif 'fear' in FRONTEND_EMOTIONS:
                    mapped_label = 'fear'
            elif label == 'trung_tinh':
                if 'neutral' in FRONTEND_EMOTIONS: mapped_label = 'neutral'

            if mapped_label and score > 0.2: # ✅ Lowered threshold
                detected_emotions.add(mapped_label)

        # Fallback: if no emotions pass the threshold, take the top-scoring one
        if not detected_emotions and results:
            top_result = max(results, key=lambda x: x['score'])
            top_label = top_result['label'].lower()
            mapped_top_label = None
            if top_label == 'tich_cuc':
                if 'joy' in FRONTEND_EMOTIONS: mapped_top_label = 'joy'
                elif 'excitement' in FRONTEND_EMOTIONS: mapped_top_label = 'excitement'
            elif top_label == 'tieu_cuc':
                if 'sadness' in FRONTEND_EMOTIONS: mapped_top_label = 'sadness'
                elif 'anger' in FRONTEND_EMOTIONS: mapped_top_label = 'anger'
                elif 'fear' in FRONTEND_EMOTIONS: mapped_top_label = 'fear'
            elif top_label == 'trung_tinh':
                if 'neutral' in FRONTEND_EMOTIONS: mapped_top_label = 'neutral'

            if mapped_top_label:
                detected_emotions.add(mapped_top_label)

        emotions = sorted(list(detected_emotions))
        print(f"✅ Emotions analyzed for sentiment field using local Hugging Face Vietnamese model: {emotions}")
        return emotions

    except Exception as e:
        print(f"❌ Error during emotion analysis for sentiment field: {e}")
        return []
