// screens/my_post_card_tile.dart
import 'package:flutter/material.dart';
import 'package:Treddit/main.dart';
import '../models/my_posts_model.dart';
import '../../../theme/decorations.dart';
import '../screens/my_post_details.dart';

class MyPostCardTile extends StatelessWidget {
  final Product postCard;
  final _baseUrl = MyApp.baseUrl;
  final String purpose;
  const MyPostCardTile({
    super.key,
    required this.postCard,
    required this.purpose
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyPostDetailsPage(
              product: postCard,
              purpose:purpose
            ),
          ),
        );
      },
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                postCard.title,
                style: mytext.headingbold(fontSize: 16, context),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: (postCard.imageUrls[0] != "$_baseUrl/res/")
                      ? Image.network(
                          height: 150,
                          postCard.imageUrls[0],
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
                    '₹${postCard.price}',
                    style: mytext.headingbold(fontSize: 15, context),
                    textAlign: TextAlign.left,
                  ),
                  const Expanded(child: const SizedBox()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
