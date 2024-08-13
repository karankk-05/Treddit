import 'package:flutter/material.dart';
import '../screens/login.dart'; // Import the LoginPage
import '../screens/signup.dart'; // Import the SignupPage

class BackgroundPage extends StatelessWidget {
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
          const Padding(
            padding: EdgeInsets.only(left: 50.0, top: 100),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect,',
                    style: TextStyle(
                      color: Color.fromARGB(
                          195, 203, 202, 202), // Same color as button text
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Trade,',
                    style: TextStyle(
                      color: Color.fromARGB(
                          195, 203, 202, 202), // Same color as button text
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Save..!!',
                    style: TextStyle(
                      color: Color.fromARGB(
                          195, 203, 202, 202), // Same color as button text
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
                  // Sign In Button as TextButton
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20.0), // Rounded corners
                      ),
                      color: theme.surface
                          .withOpacity(0.3), // Button background color
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color.fromARGB(
                                255, 203, 202, 202), // Text color
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Space between buttons
                  // Create Account Button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text(
                      'Create An Account',
                      style: TextStyle(
                        color: Color.fromARGB(255, 203, 202, 202), // Text color
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
