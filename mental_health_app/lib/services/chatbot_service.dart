// lib/services/chatbot_service.dart
import 'dart:convert';
import 'package:mental_health_app/models/chatbot_model.dart';
import 'package:mental_health_app/services/api_service.dart';
// Assuming this path

// lib/services/chatbot_service.dart
class ChatbotService {
  final ApiService _apiService;
  final String Function() _getToken; // Function để lấy token khi cần

  ChatbotService({
    required ApiService apiService,
    required String Function() getToken,
  })  : _apiService = apiService,
        _getToken = getToken;

  Future<ChatOutput> sendMessage(ChatInput chatInput) async {
    final token = _getToken(); // Lấy token khi gọi API
    final response = await _apiService.post(
      '/api/chatbot/chat',
      chatInput.toJson(),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      return ChatOutput.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get chatbot response: ${response.body}');
    }
  }
}