// lib/models/emotion_chart_model.dart
// For @required, though not strictly needed for models
import 'package:intl/intl.dart'; // For date formatting

class EmotionDataPoint {
  final DateTime date;
  final Map<String, int> emotionCounts;

  EmotionDataPoint({
    required this.date,
    required this.emotionCounts,
  });

  factory EmotionDataPoint.fromJson(Map<String, dynamic> json) {
    final String dateString = json['date'];
    final Map<String, dynamic> rawEmotionCounts = json['emotion_counts'];

    // Parse date string (assuming 'YYYY-MM-DD' format from backend)
    final DateTime parsedDate = DateTime.parse(dateString);

    // Convert raw emotion counts to Map<String, int>
    final Map<String, int> parsedEmotionCounts = rawEmotionCounts.map(
      (key, value) => MapEntry(key, value as int),
    );

    return EmotionDataPoint(
      date: parsedDate,
      emotionCounts: parsedEmotionCounts,
    );
  }

  // Helper to get a formatted date string for display
  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);
}

class EmotionChartResponse {
  final List<EmotionDataPoint> data;

  EmotionChartResponse({required this.data});

  factory EmotionChartResponse.fromJson(Map<String, dynamic> json) {
    return EmotionChartResponse(
      data: (json['data'] as List)
          .map((item) => EmotionDataPoint.fromJson(item))
          .toList(),
    );
  }
}
