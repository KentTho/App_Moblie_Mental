from transformers import pipeline

# ✅ Load Hugging Face sentiment model once globally
try:
    # This model is specifically fine-tuned for binary sentiment (positive/negative)
    sentiment_classifier = pipeline(
        "sentiment-analysis",
        model="distilbert-base-uncased-finetuned-sst-2-english"
    )
    print("✅ Sentiment model loaded.")
except Exception as e:
    sentiment_classifier = None
    print(f"❌ Failed to load sentiment model: {e}")
    print("Please ensure 'torch' or 'tensorflow' and 'transformers' are installed.")


async def analyze_sentiment(text: str) -> str:
    """
    Phân tích tổng quan cảm xúc (positive, negative, neutral).
    """
    if not text.strip() or not sentiment_classifier:
        return "neutral"

    try:
        # The pipeline call is synchronous. See notes in ai_emotion_service.py.
        result = sentiment_classifier(text)[0] # Get the first (and usually only) result
        label = result['label'].lower()

        # The 'distilbert-base-uncased-finetuned-sst-2-english' model typically
        # outputs 'positive' or 'negative'. It does not output 'neutral'.
        # So, 'neutral' will only be returned if text is empty or model not loaded.
        if label == "positive":
            return "positive"
        elif label == "negative":
            return "negative"
        else:
            # This 'else' branch should ideally not be reached if the model behaves as expected.
            # It acts as a safe fallback for unexpected labels.
            print(f"⚠️ Unexpected sentiment label from HF model: {label}. Returning 'neutral'.")
            return "neutral"

    except Exception as e:
        print(f"❌ Error during sentiment analysis: {e}")
        return "neutral"
