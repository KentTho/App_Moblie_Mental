// lib/services/suggestion_service.dart
import 'dart:convert';
import 'package:mental_health_app/models/suggestion_model.dart';
import 'package:mental_health_app/services/api_service.dart'; // Assuming this path

class SuggestionService {
  final ApiService _apiService = ApiService();

  Future<SuggestionsResponse> getSuggestions({String? emotion}) async {
    String endpoint = '/suggestions';
    if (emotion != null && emotion.isNotEmpty) {
      endpoint += '?emotion=$emotion';
    }

    final response = await _apiService.get(endpoint);

    if (response.statusCode == 200) {
      return SuggestionsResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load suggestions: ${response.body}');
    }
  }
}
