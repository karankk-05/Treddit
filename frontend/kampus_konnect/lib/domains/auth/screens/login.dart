import 'package:flutter/material.dart';
import '../widgets/fields.dart';
import 'package:kampus_konnect/domains/homepage/post_cards/screens/homepage.dart';
import '../../../theme/themes.dart';
import '../../../theme/decorations.dart';
import '../services/auth.dart';
import '../services/auth_action.dart';
import 'signup.dart';

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

  Widget _email() {
    return fields.TextField(
        controller: _emailController,
        label: "Registered Email",
        secure: false,
        context: context);
  }

  Widget _password() {
    return fields.TextField(
        controller: _passwordController,
        label: "Password",
        secure: true,
        context: context);
  }

  Widget _LoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _authActions.handleLoginButton(_emailController.text.trim(),
              _passwordController.text.trim(), context);
        },
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(100, 60)),
          backgroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.primaryContainer),
        ),
        child: Text('LOGIN', style: mytext.headingbold(fontSize: 18, context)),
      ),
    );
  }

  Widget _SignupBtn() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => signuppage(),
          ),
        );
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'New To Campus Ebay? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Ensures the view resizes when the keyboard appears
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(gradient: gradients.login),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(height: 40),
                  Text(
                    'Join The Community Now',
                    style: mytext.headingbold(fontSize: 30, context),
                  ),
                  Expanded(child: SizedBox()),
                  _email(),
                  SizedBox(height: 30.0),
                  _password(),
                  _LoginBtn(),
                  _SignupBtn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
