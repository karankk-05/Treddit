import 'package:flutter/material.dart';
import '../widgets/fields.dart';
import './custom_text_field.dart'; // Import the new file
import 'package:Treddit/domains/homepage/post_cards/screens/homepage.dart';
import '../../../theme/themes.dart';
import '../../../theme/decorations.dart';
import '../services/auth.dart';
import '../services/auth_action.dart';
import 'signup.dart';
import 'custom_appbar.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthActions _authActions = AuthActions();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _LoginBtn() {
    final theme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _authActions.handleLoginButton(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            context,
          );
        },
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(100, 60)),
          backgroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.secondaryContainer),
        ),
        child:
            Text('LOGIN', style: TextStyle(fontSize: 18, color: theme.primary)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        backgroundImage: 'assets/bg.jpeg', // Path to your background image
      ),
      resizeToAvoidBottomInset:
          true, // Ensures the view resizes when the keyboard appears
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(color: theme.surface),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .primary, // Primary color
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Sign into your account',
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface // Text color
                        ),
                  ),
                  SizedBox(height: 25),
                  CustomTextField(
                    icon: Icons.email,
                    label: "Registered Email",
                    controller: _emailController,
                  ),
                  SizedBox(height: 30.0),
                  CustomTextField(
                    icon: Icons.lock,
                    label: "Password",
                    obscureText: true,
                    controller: _passwordController,
                  ),
                  _LoginBtn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
