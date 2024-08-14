import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../homepage/post_cards/model_provider/provider.dart';
import '../homepage/post_cards/widgets/post_card_tile.dart';
import '../auth/services/auth.dart';
import '../homepage/post_cards/widgets/search_bar.dart' as CustomSearchBar;

class FoundPage extends StatefulWidget {
  @override
  State<FoundPage> createState() => _FoundPageState();
}

class _FoundPageState extends State<FoundPage> {
  final AuthService _authService = AuthService();
  String searchQuery = '';
  String selectedSection = 'found'; // Track the selected section

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
      await postCardProvider.fetchPostCards(
          query: query, purpose: selectedSection);
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

  void _showSectionSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTile(context, 'Found', Icons.search, 'found'),
              _buildTile(
                  context, 'Lost', Icons.report_problem, 'lost', Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTile(
      BuildContext context, String title, IconData icon, String section,
      [Color? highlightColor]) {
    bool isSelected = selectedSection == section;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSection = section;
          _fetchPosts(); // Refresh posts when selection changes
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
            onPressed: () => _showSectionSelector(context),
            tooltip: 'Select Section',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.onSecondary,
        onRefresh: _handleRefresh,
        child: postCardProvider.productCard.isEmpty
            ? Center(
                child: Text(
                  selectedSection == 'found' ? 'Nothing Found' : 'Nothing Lost',
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
                        purpose:selectedSection
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
