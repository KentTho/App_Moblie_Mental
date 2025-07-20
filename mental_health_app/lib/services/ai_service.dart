import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Adjust if your backend API base URL is different

  /// Calls the backend to analyze text for sentiment and emotions.
  static Future<Map<String, dynamic>> analyzeText(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/analyze-text'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to analyze text: ${response.statusCode} - ${response.body}');
    }
  }
}
