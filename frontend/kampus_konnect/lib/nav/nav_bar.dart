// ignore_for_file: must_be_immutable
import 'package:Treddit/domains/addpost/screens/add_post_options.dart';
import 'package:Treddit/domains/lost_n_found/found.dart';
import 'package:flutter/material.dart';
import '../domains/homepage/post_cards/screens/homepage.dart';
import '../domains/myposts/screens/my_posts_page.dart';
import '../domains/user_details/screens/profile_page.dart';

class MainPage extends StatefulWidget {
  int selectedIndex;
  MainPage({required this.selectedIndex});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // List of pages
  static final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MyPosts(),
    FoundPage(), // Add Wishlist page
    ProfilePage(),
    AddPostOptions()
  ];

  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
    });
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return AddPostOptions(); // Show the PreAddPostSheet widget
      },
    );
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
          heroTag: "Unique",
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
          onPressed: () => _showOptions(context),
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onSecondary,
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
                icon: widget.selectedIndex == 0
                    ? Icon(Icons.home,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer)
                    : Icon(Icons.home_outlined,
                        color: Theme.of(context).colorScheme.onSecondary),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: widget.selectedIndex == 1
                    ? Icon(Icons.list,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer)
                    : Icon(Icons.list_outlined,
                        color: Theme.of(context).colorScheme.onSecondary),
                onPressed: () => _onItemTapped(1),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.20), // Space for FloatingActionButton
              IconButton(
                icon: widget.selectedIndex == 2
                    ? Icon(Icons.find_in_page,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer)
                    : Icon(Icons.find_in_page_outlined,
                        color: Theme.of(context).colorScheme.onSecondary),
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                icon: widget.selectedIndex == 3
                    ? Icon(Icons.person,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer)
                    : Icon(Icons.person_outline,
                        color: Theme.of(context).colorScheme.onSecondary),
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
          child: _widgetOptions.elementAt(widget.selectedIndex),
        ),
        resizeToAvoidBottomInset: false);
  }
}
