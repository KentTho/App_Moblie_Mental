// lib/features/chatbot/page/chatbot_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_app/change_notifiers/chatbot_provider.dart';
import 'package:mental_health_app/models/chatbot_model.dart';
import 'package:intl/intl.dart'; // For time formatting

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    Provider.of<ChatbotProvider>(context, listen: false).sendMessage(context, text);
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('24/7 AI Support'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatbotProvider>(
              builder: (context, chatbotProvider, child) {
                _scrollToBottom(); // Scroll to bottom when messages update
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10.0),
                  itemCount: chatbotProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatbotProvider.messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.sender == MessageSender.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.deepPurple.shade900 : Colors.black87,
                fontSize: 15.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(message.timestamp),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Consumer<ChatbotProvider>(
      builder: (context, chatbotProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  ),
                  onSubmitted: (value) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8.0),
              chatbotProvider.isSending
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    )
                  : FloatingActionButton(
                      onPressed: _sendMessage,
                      backgroundColor: Colors.deepPurple,
                      mini: true,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
            ],
          ),
        );
      },
    );
  }
}
