// ignore_for_file: must_be_immutable
import 'package:Treddit/domains/addpost/screens/add_post_options.dart';
import 'package:Treddit/domains/auth/services/auth.dart';
import 'package:flutter/material.dart';
import '../domains/homepage/post_cards/screens/homepage.dart';
import '../domains/myposts/screens/my_posts_page.dart';
import '../domains/user_details/screens/profile_page.dart';
import '../domains/auth/screens/login.dart';
import '../domains/lost_n_found/found.dart';

class MainPage extends StatefulWidget {
  int selectedIndex;

  MainPage({required this.selectedIndex});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isLoggedin = false;
  final AuthService authService = AuthService();
  @override
  void initState() {
    super.initState();
    _getLoginStatus(); // Fetch login status from secure storage when widget is initialized
  }

  Future<void> _getLoginStatus() async {
    // Fetch login status from SecureStorage
    final loginStatus =
        await authService.getloginStatus(); // Replace with your method
    setState(() {
      isLoggedin = loginStatus; // Update the isLoggedin state
    });
  }

  // List of pages for logged-in users
  static final List<Widget> _widgetOptionsLoggedIn = <Widget>[
    HomePage(),
    MyPosts(),
    FoundPage(), // Wishlist page
    ProfilePage(),
    AddPostOptions()
  ];

  // List of pages for users who are not logged in
  static final List<Widget> _widgetOptionsNotLoggedIn = <Widget>[
    HomePage(),
    FoundPage(), // Only HomePage and Lost & Found for not logged in users
  ];

  // Method to handle the navigation bar item tap
  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
    });
  }

  // Show login screen when the "Login Now" button is pressed
  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LoginPage()), // Your login screen
    );
  }

  // Method to show add post options for logged-in users
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
      extendBody: true,
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Show FloatingActionButton for logged-in users, and no button for non-logged-in users
      floatingActionButton: isLoggedin
          ? FloatingActionButton(
              heroTag: "Unique",
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(500)),
              onPressed: () => _showOptions(context),
              child: Icon(Icons.add,
                  color: Theme.of(context).colorScheme.onSecondary),
              backgroundColor: Theme.of(context).colorScheme.primary,
            )
          : null,

      bottomNavigationBar: BottomAppBar(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Theme.of(context).colorScheme.secondaryContainer,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Only show Home and Lost & Found if the user is not logged in
            IconButton(
              icon: widget.selectedIndex == 0
                  ? Icon(Icons.home,
                      color: Theme.of(context).colorScheme.onSecondaryContainer)
                  : Icon(Icons.home_outlined,
                      color: Theme.of(context).colorScheme.onSecondary),
              onPressed: () => _onItemTapped(0),
            ),
            if (isLoggedin)
              Padding(
                padding: const EdgeInsets.only(right: 60.0),
                child: IconButton(
                  icon: widget.selectedIndex == 1
                      ? Icon(Icons.list,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer)
                      : Icon(Icons.list_outlined,
                          color: Theme.of(context).colorScheme.onSecondary),
                  onPressed: () => _onItemTapped(1),
                ),
              ),
            IconButton(
              icon: widget.selectedIndex == (isLoggedin ? 2 : 1)
                  ? Icon(Icons.find_in_page,
                      color: Theme.of(context).colorScheme.onSecondaryContainer)
                  : Icon(Icons.find_in_page_outlined,
                      color: Theme.of(context).colorScheme.onSecondary),
              onPressed: () => _onItemTapped(isLoggedin ? 2 : 1),
            ),
            if (isLoggedin)
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
        // Use the appropriate widget list depending on the login status
        child: isLoggedin
            ? _widgetOptionsLoggedIn.elementAt(widget.selectedIndex)
            : _widgetOptionsNotLoggedIn.elementAt(widget.selectedIndex),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
