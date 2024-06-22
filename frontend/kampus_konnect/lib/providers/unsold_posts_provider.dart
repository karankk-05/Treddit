import '../main.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/my_posts_model.dart';
import 'package:http/http.dart' as http;

class UnsoldPostsProvider with ChangeNotifier {
  List<Product> _products = [];
  final String _baseUrl = MyApp.baseUrl;
  List<Product> get products => _products;

  Future<void> fetchUnsoldPosts() async {
    // Fetch post IDs without payload
    final response = await http.post(
      Uri.parse('$_baseUrl/posts/unsold'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> postIds = jsonDecode(response.body);

      // Fetch post details for each ID
      List<Product> fetchedProducts = [];
      for (var postId in postIds) {
        final postResponse = await http.get(Uri.parse('$_baseUrl/posts/$postId'));
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
