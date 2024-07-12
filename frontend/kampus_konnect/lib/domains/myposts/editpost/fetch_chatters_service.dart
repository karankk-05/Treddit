import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/services/auth.dart';
import '../../../main.dart'; // Adjust import path as per your project structure

class MyPostsService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> fetchChatters(int postId) async {
    final String? _email = await _authService.getEmail();
    final String? _token = await _authService.getToken();
    final baseUrl = MyApp.baseUrl;

    try {
      // Step 1: Fetch chatters' emails
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/chatters'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': _email ?? "", 'token': _token ?? ""}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> emails = jsonDecode(response.body);
        final List<String> chattersEmails = List<String>.from(emails);

        // Step 2: Fetch usernames from user info
        final Map<String, String> usernames = {};

        for (var email in chattersEmails) {
          final userResponse = await http.post(
            Uri.parse('$baseUrl/user/info'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({'email': email}),
          );

          if (userResponse.statusCode == 200) {
            final userInfo = jsonDecode(userResponse.body);
            final username = userInfo['username'];
            usernames[email] = username;
          }
        }

        return usernames;
      } else {
        throw Exception('Failed to load chatters');
      }
    } catch (e) {
      throw Exception('Failed to fetch chatters: $e');
    }
  }
}
