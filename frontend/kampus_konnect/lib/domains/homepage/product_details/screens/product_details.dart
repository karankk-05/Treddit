// product_details_page.dart
import 'package:flutter/material.dart';
import 'package:kampus_konnect/domains/chat/chat_detail_screen.dart';
import 'package:provider/provider.dart';
import '../model_provider/provider.dart';
import '../../../auth/services/auth.dart';
import '../../../chat/chat_provider.dart';
import '../widgets/image_viewer.dart'; // Import the new widget
import '../widgets/collapsible_fab.dart'; // Import the collapsible FAB widget

class ProductDetailsPage extends StatefulWidget {
  final int id;

  const ProductDetailsPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool isWishlisted = false;
  String? _sender; // Make sender nullable
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchSenderEmail(); // Fetch sender's email asynchronously
    Provider.of<ProductDetailsProvider>(context, listen: false)
        .fetchPost(widget.id);
  }

  Future<void> _fetchSenderEmail() async {
    _sender = await _authService.getEmail();
    setState(() {}); // Update the UI after fetching the sender's email
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<ProductDetailsProvider>(context);
    final post = postProvider.post;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          post?.title ?? 'Loading...', // Display loading if post is null
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isWishlisted = !isWishlisted;
              });
            },
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : theme.onSurface,
            ),
          ),
          SizedBox(width: 10), // Adjust spacing as needed
        ],
      ),
      body: post == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProductImageViewer(
                      imageUrls: post.imageUrls), // Use the new widget here

                  Container(
                    width: double.infinity,
                    height: 5,
                    color: theme.surface,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '₹${post.price}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          post.body ?? '',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 5,
                    color: theme.surface,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seller: ${post.owner ?? ''}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
      backgroundColor: theme.primaryContainer,
      floatingActionButton: post != null && post.owner != _sender
          ? CollapsibleFAB(
              iconlabel: Icon(
                Icons.chat,
                color: theme.primary,
              ),
              onPressed: post.postId != null
                  ? () {
                      Provider.of<ChatProvider>(
                        context,
                        listen: false,
                      ).updatePostId(post.postId!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            postId: post.postId!,
                            reciever: post.owner!,
                            sender: _sender,
                          ),
                        ),
                      );
                    }
                  : null,
              label: "Chat Now",
            )
          : null, // Show FAB only if _sender is not null
    );
  }
}
