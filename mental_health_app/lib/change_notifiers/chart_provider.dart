// lib/change_notifiers/chart_provider.dart
import 'package:flutter/material.dart';
import 'package:mental_health_app/models/emotion_chart_model.dart';
import 'package:mental_health_app/services/chart_service.dart';
import 'package:provider/provider.dart'; // Assuming you use the Provider package
// Assuming this path

class ChartProvider with ChangeNotifier {
  final ChartService _chartService = ChartService();
  EmotionChartResponse? _emotionChartData;
  bool _isLoading = false;
  String? _errorMessage;

  EmotionChartResponse? get emotionChartData => _emotionChartData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchEmotionChartData(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUserId; // Get user ID from AuthProvider

      if (userId == null) {
        _errorMessage = "User not logged in.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      _emotionChartData = await _chartService.getEmotionsOverTime(userId);
    } catch (e) {
      _errorMessage = 'Error fetching chart data: $e';
      print('Error fetching chart data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Placeholder for AuthProvider if not provided by user
class AuthProvider with ChangeNotifier {
  String? _currentUserId = 'test_user_id'; // Replace with actual user ID logic

  String? get currentUserId => _currentUserId;

  // Example method to simulate login and set user ID
  void login(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  void logout() {
    _currentUserId = null;
    notifyListeners();
  }
}
