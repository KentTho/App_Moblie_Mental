# src/services/suggestion_service.py
from typing import List, Optional
from src.schemas.suggestion_schema import SuggestionItem

# A simple rule-based suggestion system
def get_suggestions(emotion: Optional[str] = None) -> List[SuggestionItem]:
    """
    Provides exercise suggestions based on emotion or general well-being.
    """
    suggestions = []

    # General suggestions
    suggestions.extend([
        SuggestionItem(
            type="meditation",
            title="5-Minute Mindfulness Meditation",
            description="A quick guided meditation to calm your mind and reduce stress.",
            link="https://www.youtube.com/watch?v=inpoh4yL2Qc" # Placeholder link
        ),
        SuggestionItem(
            type="music",
            title="Relaxing Ambient Music Playlist",
            description="A collection of soothing tracks to help you relax and focus.",
            link="https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M" # Placeholder link
        ),
        SuggestionItem(
            type="article",
            title="The Benefits of Journaling for Mental Health",
            description="Learn how daily journaling can improve your emotional well-being.",
            link="https://www.healthline.com/health/benefits-of-journaling" # Placeholder link
        ),
    ])

    # Emotion-specific suggestions (can be expanded)
    if emotion:
        emotion = emotion.lower()
        if "sadness" in emotion or "fear" in emotion:
            suggestions.append(
                SuggestionItem(
                    type="exercise",
                    title="Gentle Yoga for Emotional Release",
                    description="Practice gentle yoga poses to help process difficult emotions.",
                    link="https://www.youtube.com/watch?v=hJbRpHNMfCw" # Placeholder link
                )
            )
        if "anger" in emotion:
            suggestions.append(
                SuggestionItem(
                    type="exercise",
                    title="Deep Breathing Exercises for Anger Management",
                    description="Techniques to quickly calm down when feeling angry.",
                    link="https://www.youtube.com/watch?v=F2C_8_1_G0Q" # Placeholder link
                )
            )
        if "joy" in emotion or "excitement" in emotion:
            suggestions.append(
                SuggestionItem(
                    type="activity",
                    title="Practice Gratitude Journaling",
                    description="Enhance positive emotions by listing things you're grateful for.",
                    link="https://www.mindful.org/how-to-practice-gratitude/" # Placeholder link
                )
            )

    return suggestions
