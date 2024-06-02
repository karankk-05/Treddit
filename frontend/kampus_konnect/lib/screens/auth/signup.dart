import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kampus_konnect/widgets/fields.dart';

import '../../../app/appcolors.dart';
import '../../services/auth/auth.dart';
import '../../../app/decorations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth/auth_action.dart'; // Import the auth_actions file

class signuppage extends StatefulWidget {
  @override
  _signuppageState createState() => _signuppageState();
}

class _signuppageState extends State<signuppage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _showAdditionalFields = false;
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

  Widget _email(BuildContext context) {
    mydeco.context = context;
    return fields.TextField(
        label: "Email", controller: _emailController, secure: false);
  }

  Widget _username(BuildContext context) {
    mydeco.context = context;
    return fields.TextField(
        label: "Username", controller: _usernameController, secure: false);
  }

  Widget _password(BuildContext context) {
    mydeco.context = context;
    return fields.TextField(
        label: "Password", controller: _passwordController, secure: true);
  }

  Widget _conf_password(BuildContext context) {
    mydeco.context = context;
    return fields.TextField(
        label: "Confirm Password",
        controller: _confirmPasswordController,
        secure: true);
  }

  Widget _otp(BuildContext context) {
    mydeco.context = context;
    return fields.TextField(
        label: "OTP", controller: _otpController, secure: false);
  }

  Widget _RegBtn(BuildContext context) {
    mytext.context = context;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
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
              });
            },
          );
        },
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(100, 60)),
          backgroundColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
        child: Text(
          _showAdditionalFields ? 'REGISTER' : 'SEND OTP',
          style: mytext.headingbold(fontSize: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    mytext.context = context;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(gradient: gradients.login),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            child: Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(child: SizedBox()),
                    _email(context),
                    SizedBox(height: 30.0),
                    if (_showAdditionalFields) ...[
                      _username(context),
                      SizedBox(height: 30.0),
                      _password(context),
                      SizedBox(height: 30.0),
                      _conf_password(context),
                      SizedBox(height: 30.0),
                      _otp(context),
                      SizedBox(height: 30.0),
                    ],
                    _RegBtn(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
