import 'dart:async';
import 'package:flutter/material.dart';
import 'chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _messages = [];
  late Timer _pollingTimer;
  int postId;

  List<Map<String, dynamic>> get messages => _messages;

  ChatProvider(this.postId) {
    _startPolling();
  }

  void _startPolling() {
    const pollingInterval = Duration(seconds: 10); // Adjust interval as needed
    _pollingTimer = Timer.periodic(pollingInterval, (Timer timer) async {
      try {
        await fetchMessages(postId);
      } catch (error) {
        print('Error during polling: $error');
        // Handle error as needed, e.g., show a snackbar or retry mechanism
      }
    });
  }

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
      print('Error fetching messages: $error');
      throw error; // Rethrow the error to propagate it up the call stack
    }
  }

  Future<void> sendMessage(int postId, String receiver, String message) async {
    try {
      await _chatService.sendChat(postId, receiver, message);
      await fetchMessages(postId);
    } catch (error) {
      print('Error sending message: $error');
      throw error; // Rethrow the error to propagate it up the call stack
    }
  }

  void updatePostId(int newPostId) {
    postId = newPostId;
    fetchMessages(postId);
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer.cancel();
    super.dispose();
  }
}
