import 'package:flutter/material.dart';
import 'custom_text_field.dart'; // Import the custom text field
import '../../../theme/themes.dart';
import '../services/auth.dart';
import '../services/auth_action.dart'; // Import the auth_actions file
import 'custom_appbar.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _showAdditionalFields = false;
  bool _changesize = true; // State variable for app bar visibility
  bool _isLoading = false; // State variable for button loading
  final AuthActions _authActions = AuthActions();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Widget _email() {
    return CustomTextField(
      icon: Icons.email,
      label: "Email",
      controller: _emailController,
    );
  }

  Widget _username() {
    return CustomTextField(
      icon: Icons.person,
      label: "Username",
      controller: _usernameController,
    );
  }

  Widget _password() {
    return CustomTextField(
      icon: Icons.lock,
      label: "Password",
      obscureText: true,
      controller: _passwordController,
    );
  }

  Widget _confPassword() {
    return CustomTextField(
      icon: Icons.lock,
      label: "Confirm Password",
      obscureText: true,
      controller: _confirmPasswordController,
    );
  }

  Widget _otp() {
    return CustomTextField(
      icon: Icons.code,
      label: "OTP",
      controller: _otpController,
    );
  }

  Widget _regBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                setState(() {
                  _isLoading = true; // Start loading
                });

                await _authActions.handleRegisterButtonPress(
                  context: context,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  usernameController: _usernameController,
                  otpController: _otpController,
                  showAdditionalFields: _showAdditionalFields,
                  updateUI: () {
                    setState(() {
                      _showAdditionalFields = true;
                      _changesize =
                          false; // Hide the app bar when the button is clicked
                    });
                  },
                );

                setState(() {
                  _isLoading = false; // Stop loading
                });
              },
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(100, 60)),
          backgroundColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(
                color: Theme.of(context)
                    .colorScheme
                    .primary, // Progress indicator color
              )
            : Text(
                _showAdditionalFields ? 'REGISTER' : 'SEND OTP',
                style: TextStyle(
                  fontSize: 18,
                ),
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
        backgroundImage: 'assets/bg.jpeg', // Path to your background image
      ), // Conditionally display the app bar
      body: SingleChildScrollView(
        child: Container(
          height: _changesize
              ? MediaQuery.of(context).size.height * 0.6
              : MediaQuery.of(context).size.height * 1.0,
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 40),
          decoration: BoxDecoration(
            color: theme.surface, // Set background color to surface
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'Register',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary, // Primary color
                ),
              ),
              SizedBox(height: 25),
              Text(
                'Create New Account',
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface // Text color
                    ),
              ),
              SizedBox(height: 35),
              _email(),
              SizedBox(height: 10.0),
              if (_showAdditionalFields) ...[
                _username(),
                SizedBox(height: 10.0),
                _password(),
                SizedBox(height: 10.0),
                _confPassword(),
                SizedBox(height: 10.0),
                _otp(),
              ],
              _regBtn(),
            ],
          ),
        ),
      ),
    );
  }
}
