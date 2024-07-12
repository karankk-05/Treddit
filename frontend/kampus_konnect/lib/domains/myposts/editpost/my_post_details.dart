import 'package:flutter/material.dart';
import 'package:kampus_konnect/domains/chat/chat_detail_screen.dart';
import 'package:provider/provider.dart';
import '../my_posts_model.dart';
import '../my_posts_provider.dart';
import '../../auth/services/auth.dart';
import '../editpost/edit_post_details.dart';

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
  @override
  void initState() {
    super.initState();
    _fetchCredentials();
    _isSold = widget.product.isSold;
  }

  Future<void> _fetchCredentials() async {
    _email = await _authService.getEmail();
    _token = await _authService.getToken();
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
      body: Column(
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
              child: Column(
                children: [
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
                    ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //    SwitchListTile(
                      //   title: Text('Is Sold'),
                      //   value: _isSold,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _isSold = value;
                      //     });
                      //     _saveForm();
                      //   },
                      // ),
                      ElevatedButton(
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(100, 60)),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blue,
                          ),
                        ),
                        child: Text('Edit Details'),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                EditPostDetailsPage(product: product),
                          ));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}
