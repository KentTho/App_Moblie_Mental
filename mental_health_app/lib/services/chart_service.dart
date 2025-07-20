// lib/services/chart_service.dart
import 'dart:convert';
import 'package:mental_health_app/models/emotion_chart_model.dart';
import 'package:mental_health_app/services/api_service.dart'; // Assuming this path

class ChartService {
  final ApiService _apiService = ApiService();

  Future<EmotionChartResponse> getEmotionsOverTime(String userId) async {
    final response = await _apiService.get('/charts/emotions-over-time/$userId');

    if (response.statusCode == 200) {
      return EmotionChartResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load emotion chart data: ${response.body}');
    }
  }
}
