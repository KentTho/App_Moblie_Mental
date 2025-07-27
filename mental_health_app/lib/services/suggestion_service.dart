// lib/services/suggestion_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mental_health_app/change_notifiers/auth_provider.dart';
import 'package:mental_health_app/models/suggestion_model.dart';
import 'package:mental_health_app/services/api_service.dart';
import 'package:provider/provider.dart'; // Assuming this path

class SuggestionService {
  final ApiService _apiService = ApiService();
  final AuthProvider _authProvider;

  SuggestionService(BuildContext context) : _authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  
  Future<SuggestionsResponse> getSuggestions({String? emotion}) async {
    String endpoint = '/suggestions';
    if (emotion != null && emotion.isNotEmpty) {
      endpoint += '?emotion=$emotion';
    }

    final response = await _apiService.get(
      endpoint,
      headers: {'Authorization': 'Bearer ${_authProvider.firebaseToken}'},
    );

    if (response.statusCode == 200) {
      return SuggestionsResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load suggestions: ${response.body}');
    }
  }
}
