import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../main.dart';

class AuthService {
  static const String _baseUrl = MyApp.baseUrl;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<bool> sendOtp(String email) async {
    final url = Uri.parse('$_baseUrl/user/otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    return response.statusCode == 200;
  }

  Future<bool> changePassword(String email, String password, int otp) async {
    const baseUrl = MyApp.baseUrl;
    final response = await http.put(
      Uri.parse('$baseUrl/user/passwd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'passwd': password,
        'otp': otp,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      print("User updated successfully");
    } else {
      print("Failed to update user");
      throw Exception('Failed to load user');
    }
    return response.statusCode == 200;
  }

  Future<bool> createUser({
    required String email,
    required String username,
    // required String password,
    required String address,
    required String contactNo,
    required int otp,
  }) async {
    final url = Uri.parse('$_baseUrl/user/new');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'username': username,
        //'passwd': password,
        'address': address,
        'contact_no': contactNo,
        'otp': otp,
      }),
    );
if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('JWT Token: $data[token]');
      await secureStorage.write(key: 'jwt_token', value: data['token']);
      await secureStorage.write(key: 'email', value: email);
      // await secureStorage.write(key: 'login_status', value: true as String);
      await setloginStatus(true);
      String? token = await secureStorage.read(key: 'jwt_token');
      print("The saved Token is ${token}");
      return true;}
      else return false;
   
  }

  Future<bool> login(String email, int otp) async {
    final url = Uri.parse('$_baseUrl/user/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('JWT Token: $data[token]');
      await secureStorage.write(key: 'jwt_token', value: data['token']);
      await secureStorage.write(key: 'email', value: email);
      await setloginStatus(true);
      
      String? token = await secureStorage.read(key: 'jwt_token');
      print("The saved Token is ${token}");
      return true;
    } else {
      return false;
    }
  }

  Future<bool> validateToken(String email, String token) async {
    final url = Uri.parse('$_baseUrl/user/jwt/verify');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'token': token}),
    );
    print("Status code is this:-->${response.statusCode == 200}<--");

    return response.statusCode == 200;
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'jwt_token');
  }

  Future<String?> getEmail() async {
    return await secureStorage.read(key: 'email');
  }
  Future<void> setloginStatus(bool status) async {
   await secureStorage.write(key: 'login_status', value: status.toString());
  }
  Future<bool> getloginStatus() async{
    String? stored_status =  await secureStorage.read(key: 'login_status');
    if(stored_status=='true'){
      return true;
    }else{
      return false;
    }
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'jwt_token');
    await secureStorage.delete(key: 'email');
  }
}
