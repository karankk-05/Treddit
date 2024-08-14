import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../homepage/post_cards/model_provider/provider.dart';
import '../homepage/post_cards/widgets/post_card_tile.dart';
import '../auth/services/auth.dart';
import '../homepage/post_cards/widgets/search_bar.dart' as CustomSearchBar;
import 'found.dart';

class LostPage extends StatefulWidget {
  @override
  State<LostPage> createState() => _LostPageState();
}

class _LostPageState extends State<LostPage> {
  final AuthService _authService = AuthService();
  String searchQuery = '';
final String purpose="lost";
  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts({String query = ''}) async {
    final email = await _authService.getEmail();
    final token = await _authService.getToken();
    final postCardProvider =
        Provider.of<PostCardProvider>(context, listen: false);
    if (email != null && token != null) {
      await postCardProvider.fetchPostCards(query: query, purpose: purpose);
    }
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

  void _navigateToFoundPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => FoundPage()),
    );
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
          'assets/title.png',
          height: 30,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: _navigateToFoundPage,
            tooltip: 'Switch to Found Page',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.onSecondary,
        onRefresh: _handleRefresh,
        child: postCardProvider.productCard.isEmpty
            ? Center(
                child: Text(
                  'Nothing Lost',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : MasonryGridView.count(
                padding: EdgeInsets.fromLTRB(15, 10, 15, 70),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                itemCount: postCardProvider.productCard.length + 1,
                itemBuilder: (context, index) {
                  if (index == 1) {
                    return CustomSearchBar.SearchBar(
                      onSearch: _onSearch,
                    );
                  } else {
                    int adjustedIndex = index > 0 ? index - 1 : index;
                    if (adjustedIndex < postCardProvider.productCard.length) {
                      return PostCardTile(
                        postCard: postCardProvider.productCard[adjustedIndex],
                        purpose: purpose,
                      );
                    } else {
                      return Container();
                    }
                  }
                },
              ),
      ),
    );
  }
}
