// lib/providers/chat_provider.dart

import 'package:flutter/material.dart';
import 'chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _messages = [];

  List<Map<String, dynamic>> get messages => _messages;

  Future<void> fetchMessages(int postId) async {
    try {
      List<int> chatIds = await _chatService.getChatIds(postId);
      _messages = [];

      for (int id in chatIds) {
        Map<String, dynamic> messageData = await _chatService.getChat(id);
        _messages.add(messageData);
      }

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> sendMessage(
      int postId, String receiver, String message) async {
    try {
      print('trying');
      await _chatService.sendChat(postId, receiver, message);
      
      await fetchMessages(postId);
    } catch (error) {
      throw error;
    }
  }
}
