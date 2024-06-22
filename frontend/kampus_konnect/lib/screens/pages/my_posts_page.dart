// screens/my_posts.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/my_posts_provider.dart';
import '../../services/auth/auth.dart';
import '../../models/my_posts_model.dart';
import '../../app/decorations.dart';

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

  void _fetchPosts() {
    final productProvider =
        Provider.of<MyPostsProvider>(context, listen: false);
    productProvider.fetchUserPosts('keerkaran64@gmail.com');
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
            onDeletePressed: () {
              productProvider.deleteProduct(productProvider.products[index].id);
            },
            onEditPressed: () {
              // Handle edit action
            },
          );
        },
      ),
    );
  }
}

// widgets/product_tile.dart

class ProductTile extends StatefulWidget {
  final Product product;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onEditPressed;

  const ProductTile({
    Key? key,
    required this.product,
    this.onDeletePressed,
    this.onEditPressed,
  }) : super(key: key);

  @override
  _ProductTileState createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                  child: widget.product.imageUrls.isNotEmpty
                      ? Image.network(
                          widget.product.imageUrls[0],
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
                  widget.product.title,
                  style: mytext.headingtext1(fontSize: 13, context),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  widget.product.body,
                  style: mytext.headingtext1(fontSize: 12, context),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Row(
                  children: [
                    Text(
                      '₹${widget.product.price}',
                      style: mytext.headingbold(fontSize: 15, context),
                      textAlign: TextAlign.left,
                    ),
                    Expanded(child: SizedBox()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                            // Handle favorite action
                          },
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 25,
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            if (widget.onDeletePressed != null) {
                              widget.onDeletePressed!();
                            }
                          },
                          child: Icon(
                            Icons.delete,
                            color: Colors.grey,
                            size: 25,
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            if (widget.onEditPressed != null) {
                              widget.onEditPressed!();
                            }
                          },
                          child: Icon(
                            Icons.edit,
                            color: Colors.grey,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
