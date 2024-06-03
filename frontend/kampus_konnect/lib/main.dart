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
import 'package:provider/provider.dart';
import '../../providers/MyPostsProvider/my_posts_provider.dart';
import 'services/auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
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
        ChangeNotifierProvider(create: (_) => ProductProvider()),
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
          } else if (snapshot.connectionState==ConnectionState.done && snapshot.data==false) {
            print(snapshot.data);
            
             return MaterialApp(
              title: 'Mail Client',
              theme: appthemes.lighttheme,
              darkTheme: appthemes.darktheme,
              themeMode: ThemeMode.dark,
              home: LoginPage(),
              
             routes: {
                
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
