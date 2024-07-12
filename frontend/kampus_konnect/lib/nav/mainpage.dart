import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kampus_konnect/domains/chat/chat_list_screen.dart';

import '../domains/chat/chat_list_screen.dart';
import '../domains/homepage/homepage.dart';
import '../domains/addpost/add_post_page.dart';
import '../domains/myposts/my_posts_page.dart';
import '../domains/user_details/profile_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[];

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    _pages = [
      HomePage(),
      // ChatListScreen(),
      AddPost(), // Add the callback here
      MyPosts(),
      ProfilePage(),
    ];
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.of(context).pop(); // Close the drawer
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0), // Set the desired height
        child: AppBar(
          leading: Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: IconButton(
                  icon: Icon(Icons.menu,
                      color: Theme.of(context).colorScheme.onBackground),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              );
            },
          ),
          actions: [
            SizedBox(width: 50),
            // Padding(
            //   padding: const EdgeInsets.only(top: 15),
            //   child: Image.asset('assets/home_head.png', height: 25),
            // ),
            Expanded(child: SizedBox()),
          ],
        ),
      ),
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Container(
            color: Theme.of(context)
                .colorScheme
                .background, // Set the background color of the entire drawer
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerItem(
                  icon: Icons.home,
                  label: 'Home',
                  isSelected: _selectedIndex == 0,
                  onTap: () => onItemTapped(0),
                ),
                DrawerItem(
                  icon: Icons.chat,
                  label: 'Chat',
                  isSelected: _selectedIndex == 1,
                  onTap: () => onItemTapped(1),
                ),
                DrawerItemadd(
                  icon: Icons.add,
                  label: 'Add',
                  isSelected: _selectedIndex == 2,
                  onTap: () => onItemTapped(2),
                ),
                DrawerItem(
                  icon: Icons.list,
                  label: 'My Ads',
                  isSelected: _selectedIndex == 3,
                  onTap: () => onItemTapped(3),
                ),
                DrawerItem(
                  icon: Icons.person,
                  label: 'Profile',
                  isSelected: _selectedIndex == 4,
                  onTap: () => onItemTapped(4),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.onBackground
              : Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onBackground
              : Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}

class DrawerItemadd extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerItemadd({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(50),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onBackground),
      ),
      title: Text(
        label,
        style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}
