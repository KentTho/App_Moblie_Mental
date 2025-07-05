class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final List<String> tags;
  final String sentiment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.tags,
    required this.sentiment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      content: json['content'],
      tags: List<String>.from(json['tags'] ?? []),
      sentiment: json['sentiment'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "title": title,
      "content": content,
      "tags": tags,
    };
  }
}
