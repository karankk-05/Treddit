// screens/my_posts.dart
import 'package:flutter/material.dart';
import 'package:kampus_konnect/domains/auth/services/auth.dart';
import 'package:provider/provider.dart';
import '../services&providers/my_posts_provider.dart';
import '../../auth/screens/login.dart';
import '../models/my_posts_model.dart';
import '../../../theme/decorations.dart';
import 'my_post_details.dart';

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
    else
      print("email not found");
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<MyPostsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Posts'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisExtent: 300,
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: productProvider.products.length,
        itemBuilder: (context, index) {
          return ProductTile(
            product: productProvider.products[index],
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    MyPostDetailsPage(product: productProvider.products[index]),
              ));
            },
          );
        },
      ),
    );
  }
}

// widgets/product_tile.dart

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductTile({
    Key? key,
    required this.product,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: product.imageUrls.isNotEmpty
                        ? Image.network(
                            product.imageUrls[0],
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.person,
                            size: 150,
                            color: Colors.white,
                          ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    product.title,
                    style: mytext.headingtext1(fontSize: 13, context),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    product.body,
                    style: mytext.headingtext1(fontSize: 12, context),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Row(
                    children: [
                      Text(
                        '₹${product.price}',
                        style: mytext.headingbold(fontSize: 15, context),
                        textAlign: TextAlign.left,
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
