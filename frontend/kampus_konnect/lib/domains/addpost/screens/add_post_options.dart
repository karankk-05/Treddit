import 'package:flutter/material.dart';
import 'add_post_page.dart';

class AddPostOptions extends StatelessWidget {
  const AddPostOptions({Key? key}) : super(key: key);

  void _navigateToAddPost(BuildContext context, String tag) {
    Navigator.pop(context); // Close the bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPost(tag: tag),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scroll Indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Option 1: Add New Product
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Text(
                  'Wanna sell something?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Icon(Icons.add_box,
                    color: Theme.of(context).colorScheme.primary),
                TextButton(
                  onPressed: () => _navigateToAddPost(context, 'old'),
                  child: Text(
                    'Add New Product',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Option 2: Let the Community Help
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Text(
                  'Lost something?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Icon(Icons.find_in_page,
                    color: Theme.of(context).colorScheme.primary),
                TextButton(
                  onPressed: () => _navigateToAddPost(context, 'lost'),
                  child: Text(
                    'Let the Community Help',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Option 3: Let's Help the Community
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Text(
                  'Found something?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Icon(Icons.volunteer_activism,
                    color: Theme.of(context).colorScheme.primary),
                TextButton(
                  onPressed: () => _navigateToAddPost(context, 'found'),
                  child: Text(
                    'Let\'s Help the Community',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.start,
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
