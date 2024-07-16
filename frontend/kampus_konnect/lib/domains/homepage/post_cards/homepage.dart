import 'package:flutter/material.dart';
import 'package:kampus_konnect/theme/decorations.dart';
import 'post_card_provider.dart';
import 'package:provider/provider.dart';
import '../post_cards/widgets/post_card_tile.dart';
import '../../auth/services/auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final email = await _authService.getEmail();
    final token = await _authService.getToken();
    final postCardProvider =
        Provider.of<PostCardProvider>(context, listen: false);
    if (email != null && token != null) {
      await postCardProvider.fetchPostCards();
    }
  }

  bool displayAll = false;
  bool isRefreshing = false;

  Widget _appbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text('Search',
                  textAlign: TextAlign.center,
                  style: mytext.headingtext1(context, fontSize: 15)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isRefreshing = true;
    });
    await _fetchPosts();
    setState(() {
      isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final postCardProvider = Provider.of<PostCardProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("App Name Will Come"),
      ),
      body: RefreshIndicator(
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
              return _appbar(context);
            } else {
              int adjustedIndex = index > 1 ? index - 1 : index;
              if (adjustedIndex < postCardProvider.productCard.length) {
                return PostCardTile(
                  postCard: postCardProvider.productCard[adjustedIndex],
                );
              } else {
                // Handle case where adjustedIndex is out of bounds
                return Container(); // or some placeholder widget
              }
            }
          },
        ),
      ),
    );
  }
}
