import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../main.dart';
import 'model.dart'; // Assuming you have PostCard model defined

class PostCardProvider with ChangeNotifier {
  List<PostCard> _productCard = [];
  final String baseUrl = MyApp.baseUrl;

  List<PostCard> get productCard => _productCard;
  Future<void> fetchPostCards(query) async {
    try {
      // Step 1: Fetch post IDs from /posts/unsold
      final responseIds = await http.get(
        Uri.parse('$baseUrl/posts/unsold?search_query=$query'),
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
            int postId = postIds[i];
            PostCard postCard = PostCard.fromJson(postJsonList[i], postId);

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
}
