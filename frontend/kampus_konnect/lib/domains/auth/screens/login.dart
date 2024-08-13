import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_action.dart';
import '../widgets/custom_appbar.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthActions _authActions = AuthActions();
  bool _otpSent = false; // Tracks if OTP has been sent

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Widget _loginBtn() {
    final theme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          print("Button Cliked");
          if (_otpSent) {
            int otp = int.tryParse(_otpController.text.trim()) ?? 0;
            // Handle login with OTP
            _authActions.handleLoginButton(
              _emailController.text.trim(),
              otp,
              context,
            );
          } else {
            // Send OTP
            _authActions.sendOtp(
              email: _emailController.text.trim(),
              context: context,
              onOtpSent: () {
                setState(() {
                  _otpSent = true;
                });
              },
            );
          }
        },
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(100, 60)),
          backgroundColor:
              MaterialStateProperty.all<Color>(theme.secondaryContainer),
        ),
        child: Text(
          _otpSent ? 'LOGIN' : 'GET OTP',
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
      ),
      resizeToAvoidBottomInset: true,
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
                  if (_otpSent) ...[
                    const SizedBox(height: 30.0),
                    CustomTextField(
                      icon: Icons.lock,
                      label: "Enter OTP",
                      obscureText: false,
                      controller: _otpController,
                    ),
                  ],
                  _loginBtn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
