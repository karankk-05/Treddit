// screens/my_posts.dart
import 'package:flutter/material.dart';
import 'package:Treddit/domains/auth/services/auth.dart';
import 'package:provider/provider.dart';
import '../services&providers/my_posts_provider.dart';
import '../widgets/my_post_card_tile.dart'; // Import the new tile

class MyPosts extends StatefulWidget {
  @override
  _MyPostsState createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  final authService = AuthService();

  Future<void> _fetchPosts() async {
    final email = await authService.getEmail();
    final productProvider =
        Provider.of<MyPostsProvider>(context, listen: false);
    if (email != null)
      productProvider.fetchUserPosts(email);
  
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<MyPostsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Posts'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: 250,
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: productProvider.products.length,
          itemBuilder: (context, index) {
            return MyPostCardTile(
              postCard: productProvider.products[index],
            );
          },
        ),
      ),
    );
  }
}
