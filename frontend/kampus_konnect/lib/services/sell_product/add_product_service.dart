import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import '../auth/auth.dart';
import '../../main.dart';

class ProductService {
  static const String _baseUrl = MyApp.baseUrl;
  final AuthService _authService = AuthService();

  Future<bool> addProduct({
    required String title,
    required int price,
    required String description,
    required List<File> images,
  }) async {
    final email = await _authService.getEmail();
    final token = await _authService.getToken();

    if (email == null || token == null) {
      // Handle error: email or token not available
      return false;
    }

    final url = Uri.parse('$_baseUrl/user/post');

    var request = http.MultipartRequest('POST', url)
      ..fields['email'] = email
      ..fields['token'] = token
      ..fields['title'] = title
      ..fields['price'] = price.toString()
      ..fields['body'] = description;

    for (var image in images) {
      var stream = http.ByteStream(image.openRead());
      var length = await image.length();
      var multipartFile = http.MultipartFile(
        'img_${basename(image.path)}', //Ensure the name starts with 'img'
        stream,
        length,
        filename: basename(image.path),
      );
      request.files.add(multipartFile);
    }

    var response = await request.send();
    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
