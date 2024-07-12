// lib/services/chat_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:kampus_konnect/main.dart';
import '../auth/services/auth.dart';
class ChatService {
  final String baseUrl = MyApp.baseUrl;
  final AuthService _authService=AuthService();
  Future<void> sendChat(int postId, String sender, String receiver,
       String message) async {
        final token = await _authService.getToken();
    final url = Uri.parse('$baseUrl/posts/$postId/chats/new');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode(
          {'token':token, 'sender': sender, 'receiver': receiver, 'message': message}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send chat');
    }
  }

  Future<List<int>> getChatIds(
      int postId) async {
         final email = await _authService.getEmail();
            final token = await _authService.getToken();
            
    final url =
        Uri.parse('$baseUrl/posts/$postId/chats?token=$token&email=$email');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load chat IDs');
    }

    List<int> chatIds = List<int>.from(jsonDecode(response.body));
    return chatIds;
  }

  Future<Map<String, dynamic>> getChat(int chatId) async {
     final email = await _authService.getEmail();
        final token = await _authService.getToken();
    final url = Uri.parse('$baseUrl/chats/$chatId?token=$token&email=$email');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load chat');
    }

    Map<String, dynamic> chatData = jsonDecode(response.body);
    return chatData;
  }
}
