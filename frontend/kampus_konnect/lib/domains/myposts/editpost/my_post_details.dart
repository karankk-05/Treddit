import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../my_posts_model.dart';
import '../my_posts_provider.dart';
import '../../auth/services/auth.dart';
import '../editpost/edit_post_details.dart';
import '../editpost/fetch_chatters_service.dart';
import '../../chat/chat_detail_screen.dart';

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
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatDetailScreen(
        sender: sender,
        reciever: reciever,
        postId: postId,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 1.5,
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  _isSold ? 'Sold' : 'On Sale',
                  style: TextStyle(color: Colors.white),
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
              Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        if (product.imageUrls.isNotEmpty)
                          Container(
                            height: 250,
                            child: PageView.builder(
                              itemCount: product.imageUrls.length,
                              itemBuilder: (context, index) {
                                return Image.network(
                                  product.imageUrls[index],
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          )
                        else
                          Center(
                            child: Icon(
                              Icons.person,
                              size: 150,
                              color: Colors.white,
                            ),
                          )
                      ]))),
              SizedBox(
                height: 15,
              ),
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buy Requests',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _usernames.keys.map((email) {
                          final username = _usernames[email] ?? 'Unknown';
                          return Card(
                            color: Color.fromARGB(255, 109, 110, 111),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              onTap: () => _navigateToChatDetail(
                                  widget.product.owner,
                                  email,
                                  widget.product.id),
                              title: Text(
                                username,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                email,
                                style: TextStyle(
                                    color: const Color.fromARGB(
                                        179, 255, 255, 255)),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}
