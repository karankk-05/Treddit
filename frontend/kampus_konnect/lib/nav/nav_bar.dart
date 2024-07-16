import 'package:flutter/material.dart';
import '../../domains/homepage/post_cards/homepage.dart';
import '../../domains/addpost/add_post_page.dart';
import '../domains/myposts/screens/my_posts_page.dart';
import '../domains/user_details/profile_page.dart';
import '../wishlist/wishlist_page.dart'; // Import the Wishlist page

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // List of pages
  static final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MyPosts(),
    WishlistPage(), // Add Wishlist page
    ProfilePage(),
    AddPost()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody:
          true, // Ensures the body extends behind the bottom navigation bar
      backgroundColor: Colors
          .transparent, // Set the Scaffold background color to transparent
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
        onPressed: () {
          _onItemTapped(4);
        },
        child: Icon(
          Icons.add,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      bottomNavigationBar: BottomAppBar(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Theme.of(context).colorScheme.secondaryContainer,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: _selectedIndex == 0
                  ? Icon(Icons.home,
                      color: Theme.of(context).colorScheme.onSecondaryContainer)
                  : Icon(Icons.home_outlined,
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: _selectedIndex == 1
                  ? Icon(Icons.list,
                      color: Theme.of(context).colorScheme.onSecondaryContainer)
                  : Icon(Icons.list_outlined,
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
              onPressed: () => _onItemTapped(1),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.20), // Space for FloatingActionButton
            IconButton(
              icon: _selectedIndex == 2
                  ? Icon(Icons.favorite,
                      color: Theme.of(context).colorScheme.onSecondaryContainer)
                  : Icon(Icons.favorite_border,
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: _selectedIndex == 3
                  ? Icon(Icons.person,
                      color: Theme.of(context).colorScheme.onSecondaryContainer)
                  : Icon(Icons.person_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      appBar: null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(111, 77, 80, 80), // Very Dark Gray
              Color.fromARGB(255, 0, 0, 0),
            ],
          ),
        ),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }
}
