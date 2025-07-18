import os
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# Hàm phân tích cảm xúc chính xác hơn
async def analyze_sentiment(text: str) -> str:
    if not text.strip():
        return "neutral"

    try:
        prompt = f"""
You're a clinical psychologist AI specialized in detecting emotional tone from diary entries.

Analyze the overall sentiment of the following text and classify it strictly as one of the following:
- positive
- negative
- neutral
- mixed

❗ Be highly sensitive to signs of depression, hopelessness, or mental distress — these should be classified as 'negative'.
Avoid defaulting to 'neutral' unless the text is truly emotionless or objective.

Examples:
1. "I’m exhausted, nothing feels worth it anymore." => negative
2. "I feel completely hopeless. Every morning I wake up to the same cycle of sadness and loneliness." => negative
3. "It was a good day overall." => positive
4. "I bought groceries and went home." => neutral
5. "I was happy at first but then broke down crying." => mixed

Now analyze the following:
\"\"\"{text}\"\"\"

Only respond with one word: positive, negative, neutral, or mixed.
"""

        response = await client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=10,
        )

        sentiment = response.choices[0].message.content.strip().lower()

        if sentiment in ["positive", "negative", "neutral", "mixed"]:
            return sentiment
        else:
            print(f"⚠️ Unexpected sentiment response: {sentiment}")
            return "neutral"

    except Exception as e:
        print(f"❌ Error during sentiment analysis: {e}")
        return "neutral"
