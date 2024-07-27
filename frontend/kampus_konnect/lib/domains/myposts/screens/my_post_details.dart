import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/my_posts_model.dart';
import '../services&providers/my_posts_provider.dart';
import '../../auth/services/auth.dart';
import 'edit_post_details.dart';
import '../services&providers/fetch_chatters_service.dart';
import '../../chat/chat_detail_screen.dart';
import '../../homepage/product_details/widgets/image_viewer.dart';
import '../../homepage/product_details/widgets/collapsible_fab.dart';
import '../../chat/chat_provider.dart';

class MyPostDetailsPage extends StatefulWidget {
  final Product product;

  const MyPostDetailsPage({required this.product});

  @override
  _MyPostDetailsPageState createState() => _MyPostDetailsPageState();
}

class _MyPostDetailsPageState extends State<MyPostDetailsPage> {
  final AuthService _authService = AuthService();
  late String? _email;
  late String? _token;
  late bool _isSold;
  late Map<String, String> _usernames = {};

  @override
  void initState() {
    super.initState();
    _fetchCredentials();
    _fetchChatters();
    _isSold = widget.product.isSold;
  }

  Future<void> _fetchCredentials() async {
    _email = await _authService.getEmail();
    _token = await _authService.getToken();
  }

  Future<void> _fetchChatters() async {
    try {
      final service = MyPostsService();
      final usernames = await service.fetchChatters(widget.product.id);
      setState(() {
        _usernames = usernames;
      });
    } catch (e) {
      print('Error fetching chatters: $e');
      // Handle error as needed
    }
  }

  void _saveForm() {
    Provider.of<MyPostsProvider>(context, listen: false).editProduct(
      widget.product.id,
      widget.product.title,
      widget.product.body,
      widget.product.price,
      _isSold,
      _email ?? "",
      _token ?? "",
    );
  }

  void _navigateToChatDetail(String sender, String reciever, int postId) {
    Provider.of<ChatProvider>(
      context,
      listen: false,
    ).updatePostId(postId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          postId: postId,
          reciever: sender,
          sender: reciever,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final onPrimaryContainer = Theme.of(context).colorScheme.onPrimaryContainer;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.title,
          style: TextStyle(color: onPrimaryContainer),
        ),
      ),
      floatingActionButton: CollapsibleFAB(
        iconlabel: Icon(
          Icons.edit_outlined,
          color: theme.primary,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPostDetailsPage(
                product: product,
              ),
            ),
          );
        },
        label: "Edit Details",
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: Text(
                  _isSold ? 'Sold' : 'On Sale',
                  style: TextStyle(color: onPrimaryContainer),
                ),
                value: !_isSold,
                activeColor: Color.fromARGB(255, 0, 255, 21),
                inactiveTrackColor: Color.fromARGB(255, 255, 21, 0),
                onChanged: (value) {
                  setState(() {
                    _isSold = !value;
                  });
                  _saveForm();
                },
              ),
              ProductImageViewer(imageUrls: product.imageUrls),
              Container(
                width: double.infinity,
                height: 5,
                color: theme.surface,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: onPrimaryContainer,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '₹${product.price}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      product.body,
                      style: TextStyle(
                        fontSize: 16,
                        color: onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                height: 5,
                color: theme.surface,
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buy Requests',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              _usernames.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 10),
                      child: Text(
                        "No Buy Requests",
                        style: TextStyle(
                          color: onPrimaryContainer,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _usernames.keys.map((email) {
                        final username = _usernames[email] ?? 'Unknown';
                        return Column(
                          children: [
                            ListTile(
                              onTap: () => _navigateToChatDetail(
                                email,
                                widget.product.owner,
                                widget.product.id,
                              ),
                              title: Text(
                                username,
                                style: TextStyle(
                                  color: onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                email,
                                style: TextStyle(
                                  color: onPrimaryContainer.withOpacity(0.7),
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 2,
                              color: theme.surface,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}
