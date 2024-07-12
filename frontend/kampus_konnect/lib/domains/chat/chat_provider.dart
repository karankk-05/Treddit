// lib/providers/chat_provider.dart

import 'package:flutter/material.dart';
import 'chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService chatService = ChatService();
  List<int> _chatIds = [];
  Map<String, dynamic> _selectedChat = {};

  List<int> get chatIds => _chatIds;
  Map<String, dynamic> get selectedChat => _selectedChat;

  Future<void> fetchChatIds(int postId) async {
    _chatIds = await chatService.getChatIds(postId);
    print(_chatIds);
    print("in provider");
    notifyListeners();
  }

  Future<void> fetchChat(int chatId) async {
    _selectedChat = await chatService.getChat(chatId);
    notifyListeners();
  }

  Future<void> sendChat(
      int postId, String sender, String receiver, String message) async {
    await chatService.sendChat(postId, sender, receiver, message);
    fetchChatIds(postId); // Refresh chat list after sending a message
  }
}
