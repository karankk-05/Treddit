import 'package:flutter/material.dart';
import 'package:kampus_konnect/models/unsold_post_card.dart';
import 'package:kampus_konnect/providers/post_card_provider.dart';
import 'package:kampus_konnect/providers/unsold_posts_provider.dart';
import 'screens/auth/signup.dart';
import 'screens/auth/login.dart';
import 'app/appcolors.dart';
import 'screens/nav/mainpage.dart';
import 'screens/pages/add_post_page.dart';
import 'screens/pages/chat.dart';
import 'screens/pages/homepage.dart';
import 'screens/pages/my_posts_page.dart';
import 'screens/pages/profile_page.dart';
import 'package:provider/provider.dart';
import 'providers/my_posts_provider.dart';
import 'services/auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static const String baseUrl = 'http://10.0.2.2:3000';
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _isTokenValid;

  @override
  void initState() {
    super.initState();
    _isTokenValid = _checkToken();
  }

  Future<bool> _checkToken() async {
    AuthService authService = AuthService();
    String? token = await authService.getToken();
    String? email = await authService.getEmail();

    if (token != null && email != null) {
      return await authService.validateToken(email, token);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyPostsProvider()),
        ChangeNotifierProvider(create: (_) => UnsoldPostsProvider()),
        ChangeNotifierProvider(create: (_) => PostCardProvider()),
      ],
      child: FutureBuilder<bool>(
        future: _isTokenValid,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print(snapshot);
            return MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data == false) {
            print(snapshot.data);

            return MaterialApp(
              title: 'Mail Client',
              theme: appthemes.lighttheme,
              darkTheme: appthemes.darktheme,
              themeMode: ThemeMode.dark,
              home: LoginPage(),
              routes: {
                '/login': (context) => LoginPage(),
                '/main': (context) => MainPage(),
                '/home': (context) => HomePage(),
                '/chat': (context) => Chat(),
                '/addPost': (context) => AddPost(),
                '/myPosts': (context) => MyPosts(),
                '/profile': (context) => ProfilePage(),
              },
            );
          } else {
            return MaterialApp(
              title: 'Mail Client',
              theme: appthemes.lighttheme,
              darkTheme: appthemes.darktheme,
              themeMode: ThemeMode.dark,
              home: MainPage(),
              routes: {
                '/login': (context) => LoginPage(),
                '/home': (context) => HomePage(),
                '/chat': (context) => Chat(),
                '/addPost': (context) => AddPost(),
                '/myPosts': (context) => MyPosts(),
                '/profile': (context) => ProfilePage(),
              },
            );
          }
        },
      ),
    );
  }
}
