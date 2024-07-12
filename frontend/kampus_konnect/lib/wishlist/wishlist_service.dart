// wishlist_service.dart
import 'package:kampus_konnect/main.dart';
import '../domains/homepage/post_card_provider.dart';
import '../domains/homepage/product_details/product_details_provider.dart';
import '../domains/auth/services/auth.dart';
import 'dart:convert';
import 'package:http/http.dart'
    as http; // Import AuthService or adjust path as needed
import 'package:provider/provider.dart';


class WishlistService {
  final PostCardProvider postCardProvider;
  final ProductDetailsProvider productDetailsProvider;
  List<int> _wishlistedPostIds = [];
  List<int> get wishlistedPostIds => _wishlistedPostIds;
  static const String baseUrl = MyApp.baseUrl;
  final AuthService _authService = AuthService();
  WishlistService({
    required this.postCardProvider,
    required this.productDetailsProvider,
  });
  Future<void> addToWishlist(int postId) async {
    final email = await _authService.getEmail();
    final token = await _authService.getToken();
  print(email);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/wishlist/add'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'token': token,
          'post_id': postId,
        }),
      );

      if (response.statusCode == 200) {
        print('Added to wishlist');
        postCardProvider.updateWishlistStatus(postId, true);
        productDetailsProvider.updateWishlistStatus(postId, true);
      } else {
        throw Exception('Failed to add to wishlist');
      }
    } catch (e) {
      print('Error adding to wishlist: $e');
      throw e;
    }
  }

  Future<void> removeFromWishlist(int postId) async {
    final email = await _authService.getEmail();
    final token = await _authService.getToken();

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/wishlist/rm'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': email, 'post_id': postId, 'token': token}),
      );

      if (response.statusCode == 200) {
        print('Removed from wishlist');
        // Optionally handle success
        postCardProvider.updateWishlistStatus(postId, false);
        productDetailsProvider.updateWishlistStatus(postId, false);
      } else {
        throw Exception('Failed to remove from wishlist');
      }
    } catch (e) {
      print('Error removing from wishlist: $e');
      throw e;
    }
  }
  Future<void> fetchWishlistPostIds(String email,String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/wishlist'),
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
}
