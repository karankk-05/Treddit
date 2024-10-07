import 'package:Treddit/domains/auth/services/auth.dart';
import 'package:Treddit/nav/nav_bar.dart';
import 'package:flutter/material.dart';
import 'login.dart'; // Import the LoginPage
import 'signup.dart'; // Import the SignupPage

class BackgroundPage extends StatelessWidget {
  final AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/bg.jpeg', // Path to your background image
              fit: BoxFit.cover, // Adjust fit as needed
            ),
          ),

          // Blurred Background Layer
          Positioned.fill(
            child: Container(
              color: Colors.black
                  .withOpacity(0.3), // Adjust color and opacity if needed
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.1,
                top: MediaQuery.of(context).size.height * 0.15),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect,',
                    style: TextStyle(
                      color: Color.fromARGB(195, 203, 202, 202),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Trade,',
                    style: TextStyle(
                      color: Color.fromARGB(195, 203, 202, 202),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Save..!!',
                    style: TextStyle(
                      color: Color.fromARGB(195, 203, 202, 202),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 150),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      color: theme.surface.withOpacity(0.3),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color.fromARGB(255, 203, 202, 202),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                    child: const Text(
                      'Create An Account',
                      style: TextStyle(
                        color: Color.fromARGB(255, 203, 202, 202),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    "Or",
                    style: TextStyle(
                      color: Color.fromARGB(255, 203, 202, 202),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainPage(selectedIndex: 0)),
                      );
                      await authService.setloginStatus(false);
                    },
                    child: const Text(
                      'Continue Without Login',
                      style: TextStyle(
                        color: Color.fromARGB(255, 203, 202, 202),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
