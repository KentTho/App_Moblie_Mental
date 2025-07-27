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
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;
      final token = authProvider.firebaseToken;

      if (userId == null || token == null) {
        throw Exception('User not authenticated');
      }

      final data = await _chartService.getEmotionsOverTime(userId, token, days: days);
      
      _emotionChartData = data;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Chart Error: $e');
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}