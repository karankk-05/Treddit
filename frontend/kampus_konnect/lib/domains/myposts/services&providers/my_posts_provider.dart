import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/my_posts_model.dart';
import 'package:http/http.dart' as http;
import '../../../main.dart';

class MyPostsProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => _products;

  Future<void> fetchUserPosts(String email, String purpose) async {
    // Fetch post IDs
    const baseUrl = MyApp.baseUrl;
    final response = await http.post(
      Uri.parse('$baseUrl/user/posts?purpose=$purpose'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String>{'email': email}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> postIds = jsonDecode(response.body);

      // Fetch post details for each ID
      List<Product> fetchedProducts = [];
      for (var postId in postIds) {
        final postResponse =
            await http.get(Uri.parse('$baseUrl/posts/$postId'));
        if (postResponse.statusCode == 200) {
          final postJson = jsonDecode(postResponse.body);
          fetchedProducts.add(Product.fromJson(postJson));
        }
      }

      _products = fetchedProducts;
      notifyListeners();
    } else {
      throw Exception('Failed to load post IDs');
    }
  }

  Future<void> editProduct(int productId, String title, String body, int price,
      bool isSold, String email, String token) async {
    const baseUrl = MyApp.baseUrl;
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$productId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'token': token,
        'title': title,
        'body': body,
        'price': price,
        'sold': isSold,
        'email': email
      }),
    );

    if (response.statusCode == 200) {
      print("product updated successfully");
    }
  }

  void deleteProduct(int productId) {
    _products.removeWhere((product) => product.id == productId);
    notifyListeners();
  }
}
