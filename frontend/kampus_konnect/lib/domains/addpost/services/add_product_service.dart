import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import '../../auth/services/auth.dart';
import '../../../main.dart';

class ProductService {
  static const String _baseUrl = MyApp.baseUrl;
  final AuthService _authService = AuthService();

  Future<bool> addProduct({
    required String title,
    required int price,
    required String description,
    required List
        images, // Images can be a List of Uint8List (web) or List of File (mobile)
    required String purpose,
  }) async {
    try {
      final email = await _authService.getEmail();
      final token = await _authService.getToken();

      if (email == null || token == null) {
        // Handle error: email or token not available
        print('Error: Email or token not available');
        return false;
      }

      final url = Uri.parse('$_baseUrl/user/post');

      var request = http.MultipartRequest('POST', url)
        ..fields['email'] = email
        ..fields['token'] = token
        ..fields['title'] = title
        ..fields['price'] = price.toString()
        ..fields['body'] = description
        ..fields['purpose'] = purpose;

      for (var image in images) {
        if (image is Uint8List) {
          // Handle the image as Uint8List (web)
          var filename =
              'img_${DateTime.now().millisecondsSinceEpoch}.jpg'; // Generate a unique filename
          request.files.add(http.MultipartFile.fromBytes(
            'img_${filename}', // Ensure the name starts with 'img'
            image,
            filename: filename, // Use a generated filename
          ));
        } else if (image is File) {
          // Handle the image as File (mobile)
          var stream = http.ByteStream(image.openRead());
          var length = await image.length();
          request.files.add(http.MultipartFile(
            'img_${basename(image.path)}', // Ensure the name starts with 'img'
            stream,
            length,
            filename: basename(image.path),
          ));
        } else {
          // Handle unexpected type
          print('Unexpected image type: ${image.runtimeType}');
        }
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        print("Product submitted");
        return true;
      } else {
        // Debugging: Print the response status code and reason phrase
        print(
            'Error: Failed to upload product. Status code: ${response.statusCode}');
        print('Reason: ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      // Debugging: Print the error message
      print('Error: $e');
      return false;
    }
  }
}
