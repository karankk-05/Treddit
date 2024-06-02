import 'package:flutter/material.dart';
import 'screens/auth/signup.dart';
import 'screens/auth/login.dart';
import 'app/appcolors.dart';
import 'screens/nav/mainpage.dart';
import 'screens/pages/add_post_page.dart';
import 'screens/pages/chat.dart';
import 'screens/pages/homepage.dart';
import 'screens/pages/my_posts_page.dart';
import 'screens/pages/profile_page.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mail Client',
      theme: appthemes.lighttheme,
      darkTheme: appthemes.darktheme,
      themeMode: ThemeMode.dark,
      initialRoute: '/main',
      routes: {
        '/': (context) => loginpage(), // The entry point of your app
        '/main': (context) => MainPage(), // The entry point of your app
        '/home': (context) => HomePage(), // The entry point of your app
        '/chat': (context) => Chat(),
        '/addPost': (context) => AddPost(),
        '/myPosts': (context) => MyPosts(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
