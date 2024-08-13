import 'package:flutter/material.dart';
import 'auth.dart';
import '../../../theme/decorations.dart';

class AuthActions {
  final AuthService _authService = AuthService();

  Future<void> handleRegisterButtonPress({
    required BuildContext context,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController usernameController,
    required TextEditingController otpController,
    required bool showAdditionalFields,
    required Function updateUI,
  }) async {
    final email = emailController.text.trim();
    if (showAdditionalFields) {
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();
      final username = usernameController.text.trim();
      final otp = int.tryParse(otpController.text.trim()) ?? 0;

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Passwords do not match",
              style: mytext.headingtext1(fontSize: 15, context),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
        return;
      }

      final userCreated = await _authService.createUser(
        email: email,
        username: username,
        password: password,
        address: '',
        contactNo: '',
        otp: otp,
      );

      if (userCreated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "User registered successfully",
              style: mytext.headingtext1(fontSize: 15, context),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
        // Navigate to another page or perform another action
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "User registration failed",
              style: mytext.headingtext1(fontSize: 15, context),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }
    } else {
      final otpSent = await _authService.sendOtp(email);

      if (otpSent) {
        updateUI();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "OTP sent successfully",
            style: mytext.headingtext1(fontSize: 15, context),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to send OTP",
              style: mytext.headingtext1(fontSize: 15, context),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }
    }
  }
Future<void> sendOtp({
    required String email,
    required BuildContext context,
    required Function onOtpSent,
  }) async {
    final otpSent = await _authService.sendOtp(email);

    if (otpSent) {
      onOtpSent(); // Update UI to show OTP input field
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "OTP sent successfully",
                      style: TextStyle(color: Colors.black,
                      ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to send OTP",
                       style: TextStyle(color: Colors.black,),

          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    }
  }
 void handleLoginButton(String email, int otp, context) async {
  print("handling login");
    final isLoggedIn = await _authService.login(email, otp);
print(isLoggedIn);
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Login failed",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ));
    }
  }
}
