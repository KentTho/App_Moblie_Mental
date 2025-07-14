import 'dart:convert';

class Note {
  final String? id; // ✅ CHUYỂN từ int? → String?
  final String userId;
  final String title;
  final String? content;
  final String? contentJson; // ➕ thêm trường này
  final List<String> tags;
  final String? sentiment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.contentJson, // ➕ thêm vào constructor
    required this.tags,
    this.sentiment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String?, // ✅ CHỈ cần ép kiểu String
      userId: json['user_id'] as String, // ✅ CHỈ string, KHÔNG int.parse
      title: json['title'] ?? '',
      content: json['content'],
      contentJson: json['content_json'] != null
        ? jsonEncode(json['content_json']) // ✅ Chuyển Map/List → String
        : null,
      tags: List<String>.from(json['tags'] ?? []),
      sentiment: json['sentiment'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    dynamic safeContentJson;
    try {
      safeContentJson = contentJson != null ? jsonDecode(contentJson!) : null;
    } catch (e) {
      safeContentJson = null; // fallback nếu lỗi format
    }

    return {
      "user_id": userId,
      "title": title,
      "content": content,
      "content_json": safeContentJson,
      "tags": tags,
    };
  }

}
