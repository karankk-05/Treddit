// lib/services/chat_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Treddit/main.dart';
import '../auth/services/auth.dart';

class ChatService {
  final String baseUrl = MyApp.baseUrl;
  final AuthService _authService = AuthService();

  Future<void> sendChat(int postId, String receiver, String message) async {
    final token = await _authService.getToken();
    final email = await _authService.getEmail();

    final url = Uri.parse('$baseUrl/posts/$postId/chats/new');
    print('before res');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'sender': email,
          'reciever': receiver,
          'message': message,
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to send chat. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to send chat. Please try again.');
      }
    } catch (error) {
      print('An error occurred: $error');
      throw Exception(
          'Failed to send chat. Please check your connection and try again.');
    }
  }

  Future<List<int>> getChatIds(int postId) async {
    final token = await _authService.getToken();
    final email = await _authService.getEmail();
    print("-->$email");
    final url = Uri.parse('$baseUrl/posts/$postId/chats');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'email': email,
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to load chat IDs. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load chat IDs. Please try again.');
      }

      List<int> chatIds = List<int>.from(jsonDecode(response.body));
      return chatIds;
    } catch (error) {
      print('An error occurred: $error');
      throw Exception(
          'Failed to load chat IDs. Please check your connection and try again.');
    }
  }

  Future<Map<String, dynamic>> getChat(int chatId) async {
    final token = await _authService.getToken();
    final email = await _authService.getEmail();
    final url = Uri.parse('$baseUrl/chats/$chatId');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'email': email,
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to load chat. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load chat. Please try again.');
      }

      Map<String, dynamic> chatData = jsonDecode(response.body);
      return chatData;
    } catch (error) {
      print('An error occurred: $error');
      throw Exception(
          'Failed to load chat. Please check your connection and try again.');
    }
  }
}
