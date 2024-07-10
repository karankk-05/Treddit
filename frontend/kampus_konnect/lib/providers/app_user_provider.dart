import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kampus_konnect/main.dart';
import 'package:kampus_konnect/models/app_user_model.dart';

class AppUserProvider with ChangeNotifier {
  AppUser? _appUser;

  AppUser? get appUser => _appUser;

  Future<void> fetchUser(String email, String token) async {
    const baseUrl = MyApp.baseUrl;
    final response = await http.post(
      Uri.parse('$baseUrl/user/info/private'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: json.encode({'email': email, 'token': token}),
    );

    if (response.statusCode == 200) {
      final _jsonBody = jsonDecode(response.body);
      _appUser = AppUser.fromJson(_jsonBody);
      notifyListeners();
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> editUser(
    String email,
    String token,
    String username,
    String address,
    String contactNo,
  ) async {
    const baseUrl = MyApp.baseUrl;
    final response = await http.put(
      Uri.parse('$baseUrl/user/update'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'token': token,
        'contact_no': contactNo,
        'address': address,
        'email': email,
        'username': username
      }),
    );

    if (response.statusCode == 200) {
      print("User updated successfully");
    } else {
      print("Failed to update user");
      throw Exception('Failed to load user');
    }
  }
}
