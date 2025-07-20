// lib/models/suggestion_model.dart
// For @required

class SuggestionItem {
  final String type; // e.g., "meditation", "music", "article", "exercise", "activity"
  final String title;
  final String description;
  final String? link;

  SuggestionItem({
    required this.type,
    required this.title,
    required this.description,
    this.link,
  });

  factory SuggestionItem.fromJson(Map<String, dynamic> json) {
    return SuggestionItem(
      type: json['type'],
      title: json['title'],
      description: json['description'],
      link: json['link'],
    );
  }
}

class SuggestionsResponse {
  final List<SuggestionItem> suggestions;

  SuggestionsResponse({required this.suggestions});

  factory SuggestionsResponse.fromJson(Map<String, dynamic> json) {
    return SuggestionsResponse(
      suggestions: (json['suggestions'] as List)
          .map((item) => SuggestionItem.fromJson(item))
          .toList(),
    );
  }
}
