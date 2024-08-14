import 'package:Treddit/domains/homepage/post_cards/model_provider/model.dart';
import 'package:Treddit/main.dart';
import '../../product_details/screens/product_details.dart';
import 'package:flutter/material.dart';
import '../../../../theme/decorations.dart';

class PostCardTile extends StatefulWidget {
  final PostCard postCard;

  const PostCardTile({
    Key? key,
    required this.postCard,
  }) : super(key: key);

  @override
  _PostCardTileState createState() => _PostCardTileState();
}

class _PostCardTileState extends State<PostCardTile> {
  bool isFavorite = false;
  final _baseUrl = MyApp.baseUrl;

  @override
  void initState() {
    super.initState();
  }

  // void _toggleFavorite() async {
  //   try {
  //     if (isFavorite) {
  //       await widget.wishlistService.removeFromWishlist(widget.postCard.postId);
  //     } else {
  //       await widget.wishlistService.addToWishlist(widget.postCard.postId);
  //     }
  //     setState(() {
  //       isFavorite = !isFavorite;
  //     });
  //   } catch (e) {
  //     print('Error toggling wishlist: $e');
  //     // Handle error or show a snackbar
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // print(widget.postCard.image as String);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              id: widget.postCard.postId,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.postCard.title,
                        style: mytext.headingbold(fontSize: 16, context),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              15), // Adjust the radius as needed
                          child: (widget.postCard.image != null &&
                                  (widget.postCard.image as String) !=
                                      "$_baseUrl/res/")
                              ? Image.network(
                                  widget.postCard.image as String,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.photo_rounded,
                                  size: 100,
                                  color: Colors.black,
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            '₹${widget.postCard.price}',
                            style: mytext.headingbold(fontSize: 15, context),
                            textAlign: TextAlign.left,
                          ),
                          Expanded(child: const SizedBox()),
                          // GestureDetector(
                          //   //onTap: _toggleFavorite,
                          //   child: Icon(
                          //     isFavorite
                          //         ? Icons.favorite
                          //         : Icons.favorite_border,
                          //     color: isFavorite ? Colors.red : Colors.grey,
                          //     size: 25,
                          //   ),
                          // ),
                          // const SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
