
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/my_posts_model.dart';
import 'package:http/http.dart' as http;

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => _products;

  Future<void> fetchUserPosts(String email) async {
    // Fetch post IDs
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/user/posts'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'email': email}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> postIds = jsonDecode(response.body);

      // Fetch post details for each ID
      List<Product> fetchedProducts = [];
      for (var postId in postIds) {
        final postResponse = await http.get(Uri.parse('http://10.0.2.2:3000/posts/$postId'));
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

  void deleteProduct(int productId) {
    _products.removeWhere((product) => product.id == productId);
    notifyListeners();
  }
}
