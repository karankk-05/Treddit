import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/unsold_post_card.dart'; // Assuming you have PostCard model defined

class PostCardProvider with ChangeNotifier {
  List<PostCard> _productCard = [];
  List<int> _wishlistedPostIds = []; // Store wishlisted post IDs here
  final String baseUrl = MyApp.baseUrl;

  List<PostCard> get productCard => _productCard;

  Future<void> fetchPostCards() async {
    try {
      // Step 1: Fetch post IDs from /posts/unsold
      final responseIds = await http.get(
        Uri.parse('$baseUrl/posts/unsold'),
      );

      if (responseIds.statusCode == 200) {
        final List<dynamic> postIds = jsonDecode(responseIds.body);
        print("Fetched post IDs successfully: $postIds");

        // Step 2: Send post IDs to /posts/cards endpoint using a POST request
        final responseCards = await http.post(
          Uri.parse('$baseUrl/posts/cards'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(postIds),
        );

        if (responseCards.statusCode == 200) {
          final List<dynamic> postJsonList = jsonDecode(responseCards.body);
          print("Fetched post cards successfully");

          List<PostCard> fetchedProducts = [];
          for (int i = 0; i < postJsonList.length; i++) {
            // Use postIds[i] to get the postId
            int postId = postIds[i];
            // Create PostCard object and store the postId
            PostCard postCard = PostCard.fromJson(postJsonList[i], postId);

            // Check if the postId is in wishlisted post IDs
            postCard.isWishlisted = _wishlistedPostIds.contains(postId);

            fetchedProducts.add(postCard);
          }
          print(fetchedProducts);

          _productCard = fetchedProducts;
          notifyListeners();
        } else {
          print("Failed to fetch post cards");
          throw Exception('Failed to load post cards');
        }
      } else {
        print("Failed to fetch post IDs");
        throw Exception('Failed to load post IDs');
      }
    } catch (e) {
      print("Error fetching data: $e");
      throw e; // Rethrow the exception for handling in UI or higher levels
    }
  }

  Future<void> fetchWishlistPostIds(String email,String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/posts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String>{'email': email,'token':token}),
    
      );

      if (response.statusCode == 200) {
        final List<dynamic> wishlistIds = jsonDecode(response.body);
        _wishlistedPostIds = List<int>.from(wishlistIds);
        print("Fetched wishlisted post IDs successfully: $_wishlistedPostIds");
      } else {
        print("Failed to fetch wishlisted post IDs");
        throw Exception('Failed to load wishlisted post IDs');
      }
    } catch (e) {
      print("Error fetching wishlist data: $e");
      throw e;
    }
  }
  void updateWishlistStatus(int postId, bool isWishlisted) {
    final index = _productCard.indexWhere((post) => post.postId == postId);
    if (index != -1) {
      _productCard[index].isWishlisted = isWishlisted;
      notifyListeners();
    }
  }
}
