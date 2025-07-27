// lib/services/chatbot_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mental_health_app/change_notifiers/auth_provider.dart';
import 'package:mental_health_app/models/chatbot_model.dart';
import 'package:mental_health_app/services/api_service.dart';
import 'package:provider/provider.dart'; // Assuming this path

class ChatbotService {
  final ApiService _apiService = ApiService();
  final AuthProvider _authProvider
  
  ;

ChatbotService(BuildContext context) : _authProvider = Provider.of<AuthProvider>(context, listen: false);


  Future<ChatOutput> sendMessage(ChatInput chatInput) async {
    final response = await _apiService.post(
      '/chatbot/chat',
       chatInput.toJson(),
       headers: {'Authorization': 'Bearer ${_authProvider.firebaseToken}'},
      );

    if (response.statusCode == 200) {
      return ChatOutput.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get chatbot response: ${response.body}');
    }
  }
}
