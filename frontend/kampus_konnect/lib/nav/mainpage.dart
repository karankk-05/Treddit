import 'package:flutter/material.dart';
import '../domains/homepage/post_cards/homepage.dart';
import '../domains/addpost/add_post_page.dart';
import '../domains/myposts/screens/my_posts_page.dart';
import '../domains/user_details/profile_page.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your App Title'),
      ),
      body: BottomBar(
        child: TabBar(
          controller: tabController,
          tabs: [
            Tab(
                icon: Icon(
              Icons.home,
              color: _selectedIndex == 0
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.onPrimaryContainer,
            )),
            Tab(
                icon: Icon(
              Icons.add,
              color: _selectedIndex == 1
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.onPrimaryContainer,
            )),
            Tab(
                icon: Icon(
              Icons.list,
              color: _selectedIndex == 2
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.onPrimaryContainer,
            )),
            Tab(
                icon: Icon(
              Icons.person,
              color: _selectedIndex == 3
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.onPrimaryContainer,
            )),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        fit: StackFit.expand,
        icon: (width, height) => Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: null,
            icon: Icon(
              Icons.arrow_upward_rounded,
              size: width,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(500),
        duration: Duration(seconds: 1),
        curve: Curves.decelerate,
        showIcon: true,
        width: MediaQuery.of(context).size.width * 0.7,
        barColor: Theme.of(context).colorScheme.secondaryContainer,
        start: 10,
        end: 0,
        offset: 10,
        barAlignment: Alignment.bottomCenter,
        iconHeight: 35,
        iconWidth: 35,
        reverse: false,
        barDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(500),
        ),
        iconDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          borderRadius: BorderRadius.circular(500),
        ),
        hideOnScroll: true,
        scrollOpposite: false,
        onBottomBarHidden: () {},
        onBottomBarShown: () {},
        body: (context, controller) => TabBarView(
          controller: tabController,
          physics: const BouncingScrollPhysics(),
          children: [
            HomePage(),
            AddPost(),
            MyPosts(),
            ProfilePage(),
          ],
        ),
      ),
    );
  }
}
