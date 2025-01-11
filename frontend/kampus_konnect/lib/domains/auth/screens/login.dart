import 'package:Treddit/domains/auth/services/auth.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_action.dart';
import '../widgets/custom_appbar.dart';
import 'background_page.dart';
import '../../../nav/nav_bar.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthActions _authActions = AuthActions();
  final AuthService authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _loginBtn() {
    final theme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          String email = _emailController.text.trim();
          String password = _passwordController.text.trim();

          if (email.isEmpty || password.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please fill in all fields')),
            );
            return;
          }

          // Handle login with email and password
          _authActions.handleLoginButton(
            email,
            password,
            context,
          );
        },
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(100, 60)),
          backgroundColor:
              MaterialStateProperty.all<Color>(theme.secondaryContainer),
        ),
        child: Text(
          'LOGIN',
          style: TextStyle(fontSize: 18, color: theme.primary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        backgroundImage: 'assets/bg.jpeg',
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  BackgroundPage(), // Replace with the page you want to navigate to
            ),
          );
        },
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
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
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sign into your account',
                    style: TextStyle(fontSize: 14, color: theme.onSurface),
                  ),
                  const SizedBox(height: 25),
                  CustomTextField(
                    icon: Icons.email,
                    label: "Registered Email",
                    controller: _emailController,
                  ),
                  const SizedBox(height: 30.0),
                  CustomTextField(
                    icon: Icons.lock,
                    label: "Password",
                    obscureText: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 20),
                  _loginBtn(),
                  Text(
                    "Or",
                    style: TextStyle(
                      color: Color.fromARGB(255, 51, 50, 50),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainPage(
                                  selectedIndex: 0,
                                )),
                      );
                      await authService.setloginStatus(false);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text(
                      'Continue Without Login',
                      style: TextStyle(
                        color: Color.fromARGB(255, 94, 92, 92), // Text color
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
