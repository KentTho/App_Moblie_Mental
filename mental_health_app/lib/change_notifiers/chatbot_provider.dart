// lib/change_notifiers/chatbot_provider.dart
import 'package:flutter/material.dart';
import 'package:mental_health_app/models/chatbot_model.dart';
import 'package:mental_health_app/services/chatbot_service.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_app/change_notifiers/auth_provider.dart'; // Assuming this path

class ChatbotProvider with ChangeNotifier {
  final ChatbotService _chatbotService = ChatbotService();
  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  String? _errorMessage;

  List<ChatMessage> get messages => _messages;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  // Initialize with a welcome message
  ChatbotProvider() {
    _messages.add(ChatMessage(
      text: "Hello! How can I help you today?",
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> sendMessage(BuildContext context, String text) async {
    if (text.trim().isEmpty) return;

    _isSending = true;
    _errorMessage = null;
    _messages.add(ChatMessage(
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final UserId = authProvider.userId;

      if (UserId == null) {
        _errorMessage = "User not logged in. Cannot send message.";
        _isSending = false;
        notifyListeners();
        return;
      }

      final chatInput = ChatInput(message: text, userId: UserId);
      final chatOutput = await _chatbotService.sendMessage(chatInput);

      _messages.add(ChatMessage(
        text: chatOutput.response,
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _errorMessage = 'Error sending message: $e';
      _messages.add(ChatMessage(
        text: "Sorry, I couldn't get a response. Please try again.",
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
      ));
      print('Error sending message: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
