import 'package:Treddit/domains/addpost/screens/add_post_options.dart';
import 'package:flutter/material.dart';
import 'package:Treddit/domains/auth/screens/background_page.dart';
import 'package:Treddit/domains/chat/chat_provider.dart';
import 'package:Treddit/domains/user_details/model_provider/app_user_provider.dart';
import 'package:Treddit/domains/homepage/post_cards/model_provider/provider.dart';
import 'package:Treddit/domains/homepage/product_details/model_provider/provider.dart';
import 'domains/auth/screens/login.dart';
import 'theme/themes.dart';
import 'nav/nav_bar.dart';
import 'domains/homepage/post_cards/screens/homepage.dart';
import 'domains/myposts/screens/my_posts_page.dart';
import 'domains/user_details/screens/profile_page.dart';
import 'package:provider/provider.dart';
import 'domains/myposts/services&providers/my_posts_provider.dart';
import 'domains/auth/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static const String baseUrl = 'http://206.1.53.36:80';
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

    try {
      String? token = await authService.getToken();
      String? email = await authService.getEmail();
      if (token != null && email != null) {
        return await authService.validateToken(email, token);
      }
      return false;
    } catch (_) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyPostsProvider()),
        ChangeNotifierProvider(create: (_) => ProductDetailsProvider()),
        ChangeNotifierProvider(create: (_) => PostCardProvider()),
        ChangeNotifierProvider(create: (_) => AppUserProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider(1))
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
              title: 'Treddit',
              theme: appthemes.lighttheme,
              home: BackgroundPage(),
              routes: {
                '/login': (context) => LoginPage(),
                '/main': (context) => MainPage(selectedIndex: 0),
                '/home': (context) => HomePage(),
                // '/chat': (context) => Chat(),
                '/addPostOptions': (context) => AddPostOptions(),
                '/myPosts': (context) => MyPosts(),
                '/profile': (context) => ProfilePage(),
              },
            );
          } else {
            return MaterialApp(
              title: 'Treddit',
              theme: appthemes.lighttheme,
              home: MainPage(
                selectedIndex: 0,
              ),
              routes: {
                '/login': (context) => LoginPage(),
                '/home': (context) => HomePage(),
                // '/chat': (context) => Chat(),
                '/addPostOptions': (context) => AddPostOptions(),
                '/myPosts': (context) => MyPosts(),
                '/profile': (context) => ProfilePage(),
                '/main': (context) => MainPage(selectedIndex: 0),
              },
            );
          }
        },
      ),
    );
  }
}
