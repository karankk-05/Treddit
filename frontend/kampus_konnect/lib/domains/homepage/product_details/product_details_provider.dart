import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_details_model.dart';
import '../../../main.dart';



class ProductDetailsProvider with ChangeNotifier {
  ProductDetails? _post;
  
  ProductDetails? get post => _post;

  Future<void> fetchPost(int postId) async {
    final baseUrl = MyApp.baseUrl; // Replace with your backend base URL
    final url = Uri.parse('$baseUrl/posts/$postId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        _post = ProductDetails.fromJson(jsonBody);
        notifyListeners();
      } else {
        throw Exception('Failed to load post details');
      }
    } catch (e) {
      print('Error fetching post: $e');
      throw e; // Rethrow the exception for handling in UI or higher levels
    }
  }
}