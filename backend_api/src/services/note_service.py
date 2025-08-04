# src/services/note_service.py

import re
from typing import List

# Từ khóa mẫu để xác định chủ đề
TOPIC_KEYWORDS = {
    "Công việc": ["công việc", "deadline", "dự án", "phỏng vấn", "sếp", "bận rộn", "áp lực"],
    "Tình cảm": ["yêu", "chia tay", "tình yêu", "người yêu", "hẹn hò", "cảm xúc", "tình cảm"],
    "Gia đình": ["gia đình", "ba mẹ", "cha mẹ", "con cái", "anh chị", "nhà", "bố", "mẹ"],
    "Học tập": ["học", "bài tập", "lớp học", "trường", "giáo viên", "điểm số", "thi"],
    "Sức khỏe": ["sức khỏe", "bệnh", "mệt", "khỏe", "ốm", "bác sĩ", "thuốc"],
    "Tài chính": ["tiền", "chi tiêu", "lương", "vay", "ngân hàng", "tài chính"],
    "Bạn bè": ["bạn", "tình bạn", "hẹn", "nói chuyện", "cãi nhau", "kết bạn"]
}


def detect_topics_from_content(content: str) -> List[str]:
    """
    Trích xuất chủ đề dựa vào từ khóa có trong nội dung ghi chú.

    Args:
        content (str): Nội dung ghi chú.

    Returns:
        List[str]: Danh sách các chủ đề phù hợp.
    """
    content_lower = content.lower()
    matched_topics = []

    for topic, keywords in TOPIC_KEYWORDS.items():
        for keyword in keywords:
            if re.search(rf'\b{re.escape(keyword)}\b', content_lower):
                matched_topics.append(topic)
                break  # Chỉ cần 1 từ khóa là gắn tag chủ đề

    return matched_topics if matched_topics else ["Khác"]
