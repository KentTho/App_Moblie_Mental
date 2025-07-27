// lib/change_notifiers/chatbot_provider.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_app/models/chatbot_model.dart';
import 'package:mental_health_app/services/chatbot_service.dart';
import 'package:mental_health_app/change_notifiers/auth_provider.dart'; // Assuming this path

class ChatbotProvider with ChangeNotifier {
  final ChatbotService _chatbotService;

  // Danh sách các tin nhắn trong đoạn hội thoại
  final List<ChatMessage> _messages = [];

  // Trạng thái đang gửi tin nhắn
  bool _isSending = false;

  // Thông báo lỗi nếu có
  String? _errorMessage;

  // Constructor với chatbot service, đồng thời khởi tạo tin nhắn chào mừng
  ChatbotProvider({required ChatbotService chatbotService})
      : _chatbotService = chatbotService {
    _messages.add(
      ChatMessage(
        text: "Hello! How can I help you today?",
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
      ),
    );
  }

  // Getter để truy cập dữ liệu từ UI
  List<ChatMessage> get messages => _messages;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  /// Gửi tin nhắn từ người dùng và nhận phản hồi từ chatbot
  Future<void> sendMessage(BuildContext context, String text) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Delay nhỏ để tăng UX

    // Bỏ qua nếu người dùng nhập chuỗi rỗng
    if (text.trim().isEmpty) return;

    _isSending = true;
    _errorMessage = null;

    // Thêm tin nhắn người dùng vào danh sách
    _messages.add(
      ChatMessage(
        text: text,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();

    try {
      // Lấy userId từ AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;

      if (userId == null) {
        _errorMessage = "Please login to use the chatbot";
        _isSending = false;
        notifyListeners();
        return;
      }

      // Gửi request đến chatbot service
      final chatInput = ChatInput(message: text, userId: userId);
      final chatOutput = await _chatbotService.sendMessage(chatInput);

      // Thêm phản hồi từ chatbot vào danh sách
      _messages.add(
        ChatMessage(
          text: chatOutput.response,
          sender: MessageSender.bot,
          timestamp: DateTime.now(),
        ),
      );

      _errorMessage = null; // Xóa lỗi nếu có trước đó
    } catch (e) {
      // Gặp lỗi khi gọi API hoặc xử lý
      _errorMessage = 'Error sending message: $e';
      _messages.add(
        ChatMessage(
          text: "Sorry, I couldn't get a response. Please try again.",
          sender: MessageSender.bot,
          timestamp: DateTime.now(),
        ),
      );
      debugPrint('Error sending message: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
