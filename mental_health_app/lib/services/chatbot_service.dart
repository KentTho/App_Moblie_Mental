// lib/services/chatbot_service.dart
import 'dart:convert';
import 'package:mental_health_app/models/chatbot_model.dart';
import 'package:mental_health_app/services/api_service.dart'; // Assuming this path

class ChatbotService {
  final ApiService _apiService = ApiService();

  Future<ChatOutput> sendMessage(ChatInput chatInput) async {
    final response = await _apiService.post('/chatbot/chat', chatInput.toJson());

    if (response.statusCode == 200) {
      return ChatOutput.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get chatbot response: ${response.body}');
    }
  }
}
