import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Treddit/main.dart';
import 'package:Treddit/domains/user_details/app_user_model.dart';

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
        'username': username,
      }),
    );

    if (response.statusCode == 200) {
      print("User updated successfully");
    } else {
      print("Failed to update user");
      throw Exception('Failed to load user');
    }
  }

  Future<void> updateProfilePic(
    String email,
    String token,
    File profileImage,
  ) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${MyApp.baseUrl}/user/profile/pic'),
    );

    final fileName = profileImage.path.split('/').last;

    request.fields['email'] = email;
    request.fields['token'] = token;
    request.fields['fname'] = fileName;

    request.files.add(await http.MultipartFile.fromPath(
      'data',
      profileImage.path,
    ));

    final response = await request.send();

    if (response.statusCode == 200) {
      print("Profile picture updated successfully");
    } else {
      print("Failed to update profile picture");
      throw Exception('Failed to update profile picture');
    }
  }
}
