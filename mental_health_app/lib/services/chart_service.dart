// lib/services/chart_service.dart
import 'dart:convert';
import 'package:mental_health_app/models/emotion_chart_model.dart';
import 'package:mental_health_app/services/api_service.dart'; // Assuming this path


class ChartService {
  final ApiService _apiService = ApiService();
  static const String _baseUrl = 'http://10.0.2.2:8000'; // Khai báo baseUrl

  Future<EmotionChartResponse> getEmotionsOverTime(
    String firebaseUid, 
    String firebaseToken,
    {int days = 30}
  ) async {
    final response = await _apiService.get(
      '$_baseUrl/api/charts/emotions-over-time/$firebaseUid?days=$days',
      headers: {'Authorization': 'Bearer $firebaseToken'},
    );
    
    if (response.statusCode == 200) {
      return EmotionChartResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load chart data: ${response.statusCode}');
    }
  }
}
