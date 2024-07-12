import 'package:flutter/material.dart';
import 'package:kampus_konnect/domains/chat/chat_list_screen.dart';
import 'package:provider/provider.dart';
import 'product_details_provider.dart'; // Import the provider
import '../../../wishlist/wishlist_service.dart'; // Import WishlistService
import '../post_card_provider.dart';
class ProductDetailsPage extends StatefulWidget {
  final int id;
  final bool? isWishlisted;

  const ProductDetailsPage({
    Key? key,
    required this.id,
    required this.isWishlisted,
  }) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool dealInitiated = false;
  late bool isWishlisted;

  late WishlistService _wishlistService;

  @override
  void initState() {
    super.initState();
    _wishlistService = WishlistService(
      postCardProvider: Provider.of<PostCardProvider>(context, listen: false),
      productDetailsProvider:
          Provider.of<ProductDetailsProvider>(context, listen: false),
    );
    isWishlisted = widget.isWishlisted ?? false;
    print(widget.id);
    Provider.of<ProductDetailsProvider>(context, listen: false)
        .fetchPost(widget.id);
        
  }

  void _toggleWishlist() async {
    try {
      if (isWishlisted) {
        await _wishlistService.removeFromWishlist(widget.id);
      } else {
        await _wishlistService.addToWishlist(widget.id);
      }
      setState(() {
        isWishlisted = !isWishlisted;
      });
    } catch (e) {
      print('Error toggling wishlist: $e');
      // Handle error, e.g., show a Snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<ProductDetailsProvider>(context);
    final post = postProvider.post;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          post?.title ?? 'Loading...', // Use the title of the product
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: post == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          if (post.imageUrls.isNotEmpty)
                            Container(
                              height: 250, // Adjust height as necessary
                              child: PageView.builder(
                                itemCount: post.imageUrls.length,
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    post.imageUrls[index],
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
                              ElevatedButton(
                                style: ButtonStyle(
                                  minimumSize:
                                      MaterialStateProperty.all(Size(100, 60)),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    isWishlisted ? Colors.red : Colors.white,
                                  ),
                                ),
                                child: Text(
                                  isWishlisted
                                      ? 'Remove From Favorites'
                                      : 'Add To favourites',
                                  style: TextStyle(
                                    color: isWishlisted
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                onPressed: _toggleWishlist,
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                  minimumSize:
                                      MaterialStateProperty.all(Size(100, 60)),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    dealInitiated
                                        ? Color.fromARGB(255, 12, 69, 7)
                                        : Colors.green,
                                  ),
                                ),
                                child: Text(
                                  dealInitiated ? 'Chat Now' : 'Make a Deal',
                                ),
                                onPressed: () {
                                  setState(() {
                                    dealInitiated = !dealInitiated;
                                     Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                           ChatListScreen(postId: post.postId)
                                      ),
                                    );
                                  });
                                  // Handle chat or deal initiation action
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
                            post.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '₹${post.price}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            post.body,
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
                  // Seller information card
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seller: ${post.owner}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Address card
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Address:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Sample Address', // Use the address from your data
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          child: ElevatedButton(
                            style: ButtonStyle(
                              minimumSize:
                                  MaterialStateProperty.all(Size(120, 60)),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.blue,
                              ),
                            ),
                            onPressed: () {
                              // Handle go to address action
                            },
                            child: Text(
                              'Go to Address',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}
