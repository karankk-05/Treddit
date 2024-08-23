import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../model_provider/provider.dart';
import '../widgets/post_card_tile.dart';
import '../widgets/search_bar.dart'
    as CustomSearchBar; // Import the SearchBar widget with an alias
import '../../../auth/services/auth.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoggedin = false;
  String searchQuery = '';
  final String purpose = "old";
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _getLoginStatus();
  }

  Future<void> _getLoginStatus() async {
    // Fetch login status from SecureStorage
    final loginStatus =
        await authService.getloginStatus(); // Replace with your method
    setState(() {
      isLoggedin = loginStatus; // Update the isLoggedin state
    });
  }

  Future<void> _fetchPosts({String query = ''}) async {
    final postCardProvider =
        Provider.of<PostCardProvider>(context, listen: false);

    await postCardProvider.fetchPostCards(query: query, purpose: purpose);
  }

  bool isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() {
      isRefreshing = true;
    });
    await _fetchPosts();
    setState(() {
      isRefreshing = false;
    });
  }

  void _onSearch(String query) {
    setState(() {
      searchQuery = query;
    });
    _fetchPosts(query: query);
  }

  void _onLoginPressed() {
    Navigator.pushReplacementNamed(
        context, '/login'); // Replace with your login route
  }

  @override
  Widget build(BuildContext context) {
    final postCardProvider = Provider.of<PostCardProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        title: Image.asset(
          'assets/title.png', // Path to your image asset
          height: 30, // Adjust the height as needed
          fit: BoxFit.contain, // Ensure the image fits within the space
        ),
        actions: [
          if (!isLoggedin) // Show the button only if not logged in
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextButton(
                onPressed: _onLoginPressed,
                child: Text(
                  'Log In Now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.onSecondary,
        onRefresh: _handleRefresh,
        child: MasonryGridView.count(
          padding: EdgeInsets.fromLTRB(15, 10, 15, 70),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          itemCount:
              postCardProvider.productCard.length + 1, // +1 for the search bar
          itemBuilder: (context, index) {
            if (index == 1) {
              return CustomSearchBar.SearchBar(
                onSearch: _onSearch,
              ); // Use the SearchBar widget with the alias
            } else {
              int adjustedIndex = index > 0 ? index - 1 : index;
              if (adjustedIndex < postCardProvider.productCard.length) {
                return PostCardTile(
                  postCard: postCardProvider.productCard[adjustedIndex],
                  purpose: purpose,
                );
              } else {
                return Container(); // or some placeholder widget
              }
            }
          },
        ),
      ),
    );
  }
}
