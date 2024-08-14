import 'package:flutter/material.dart';
import 'package:Treddit/domains/auth/services/auth.dart';
import 'package:provider/provider.dart';
import '../services&providers/my_posts_provider.dart';
import '../widgets/my_post_card_tile.dart';

class MyPosts extends StatefulWidget {
  @override
  _MyPostsState createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  String selectedCategory = 'lost'; // Default category is 'For Sale'

  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final email = await authService.getEmail();
    final productProvider =
        Provider.of<MyPostsProvider>(context, listen: false);
    if (email != null) {
      await productProvider.fetchUserPosts(email, selectedCategory);
    }
  }

  void _showCategorySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTile(context, 'For Sale', Icons.sell, 'old'),
              _buildTile(context, 'Found', Icons.volunteer_activism, 'found'),
              _buildTile(context, 'Lost', Icons.search, 'lost', Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTile(
      BuildContext context, String title, IconData icon, String category,
      [Color? highlightColor]) {
    bool isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
          _fetchPosts(); // Refresh posts when the category changes
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.surface
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? highlightColor ?? Theme.of(context).colorScheme.primary
                : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? highlightColor ?? Theme.of(context).colorScheme.primary
                    : Colors.grey),
            SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? highlightColor ?? Theme.of(context).colorScheme.primary
                    : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyPostsProvider>(
      builder: (context, productProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('My Posts'),
            actions: [
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _showCategorySelector(context),
                tooltip: 'Select Category',
              ),
            ],
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
      },
    );
  }
}
