// lib/change_notifiers/chart_provider.dart
import 'package:flutter/material.dart';
import 'package:mental_health_app/change_notifiers/auth_provider.dart';
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

  // lib/change_notifiers/chart_provider.dart
  Future<void> fetchEmotionChartData(BuildContext context, {required int days}) async {
    if (!_isLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;
      final firebaseToken = authProvider.firebaseToken;  // Lấy token từ authProvider

      if (userId == null || firebaseToken == null) {
        throw Exception('User not authenticated');
      }

      // Truyền cả userId và firebaseToken
      final data = await _chartService.getEmotionsOverTime(userId, firebaseToken, days: days);
      
      if (data != _emotionChartData) {
        _emotionChartData = data;
        _errorMessage = null;
        notifyListeners();
      }
    } on Exception catch (e) {
      _errorMessage = e.toString();
      debugPrint('Chart Error: $e');
      notifyListeners();
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}