import 'dart:convert';

class Note {
  final String? id;
  final String userId;
  final String title;
  final String? content;
  final String? contentJson;
  final List<String> tags;
  final String? sentiment;
  final List<String>? emotions; // ✅ NEW: Add emotions field
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.contentJson,
    required this.tags,
    this.sentiment,
    this.emotions, // ✅ NEW: Include in constructor
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      title: json['title'] ?? '',
      content: json['content'],
      contentJson: json['content_json'] != null
        ? jsonEncode(json['content_json'])
        : null,
      tags: List<String>.from(json['tags'] ?? []),
      sentiment: json['sentiment'] as String?,
      emotions: json['emotions'] != null // ✅ NEW: Parse emotions from JSON
          ? List<String>.from(json['emotions'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    dynamic safeContentJson;
    try {
      safeContentJson = contentJson != null ? jsonDecode(contentJson!) : null;
    } catch (e) {
      safeContentJson = null; // fallback if format error
    }

    return {
      "user_id": userId,
      "title": title,
      "content": content,
      "content_json": safeContentJson,
      "tags": tags,
      // "sentiment": sentiment, // Backend determines sentiment
      // "emotions": emotions, // Backend determines emotions
    };
  }
}
