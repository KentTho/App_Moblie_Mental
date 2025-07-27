// lib/change_notifiers/suggestion_provider.dart
import 'package:flutter/material.dart';
import 'package:mental_health_app/models/suggestion_model.dart';
import 'package:mental_health_app/services/suggestion_service.dart';

class SuggestionProvider with ChangeNotifier {
  final SuggestionService _suggestionService;
  List<SuggestionItem> _suggestions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SuggestionItem> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SuggestionProvider(BuildContext context) 
    : _suggestionService = SuggestionService(context);


  Future<void> fetchSuggestions({String? emotion}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _suggestionService.getSuggestions(emotion: emotion);
      _suggestions = response.suggestions;
    } catch (e) {
      _errorMessage = 'Error fetching suggestions: $e';
      print('Error fetching suggestions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
