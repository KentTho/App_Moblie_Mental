// lib/models/chatbot_model.dart
// For @required

enum MessageSender { user, bot }

class ChatMessage {
  final String text;
  final MessageSender sender;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}

class ChatInput {
  final String message;
  final String userId;

  ChatInput({required this.message, required this.userId});

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user_id': userId,
    };
  }
}

class ChatOutput {
  final String response;

  ChatOutput({required this.response});

  factory ChatOutput.fromJson(Map<String, dynamic> json) {
    return ChatOutput(
      response: json['response'],
    );
  }
}
