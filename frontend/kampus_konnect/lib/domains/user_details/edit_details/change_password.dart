import 'package:flutter/material.dart';
import '../../auth/services/auth.dart';

class ChangePasswordPage extends StatefulWidget {
  final String? email;
  ChangePasswordPage({required this.email});
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  late TextEditingController _otpController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _getOtp() async {
    if (widget.email == null || widget.email!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email is required to send OTP.')),
      );
      return;
    }

    bool otpSent = await _authService.sendOtp(widget.email!);
    if (otpSent) {
      setState(() {
        _otpSent = true;
      });
    } else {
      // Handle OTP sending failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP. Please try again.')),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      bool success = await _authService.changePassword(widget.email!,
          _newPasswordController.text, int.parse(_otpController.text));

      if (success) {
        // Handle password change success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password changed successfully.')),
        );
        Navigator.of(context).pop();
      } else {
        // Handle password change failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to change password. Please try again.')),
        );
      }
    }
  }

  Widget _getOtpBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _getOtp,
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(Size(100, 60)),
          backgroundColor: WidgetStateProperty.all<Color>(
              Theme.of(context).colorScheme.primaryContainer),
        ),
        child: Text('Get OTP'),
      ),
    );
  }

  Widget _changePasswordBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _changePassword,
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(Size(100, 60)),
          backgroundColor: WidgetStateProperty.all<Color>(
              Theme.of(context).colorScheme.secondaryContainer),
        ),
        child: Text('Change Password'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  if (_otpSent) ...[
                    TextFormField(
                      controller: _otpController,
                      decoration: InputDecoration(labelText: 'OTP'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter OTP';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(labelText: 'New Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration:
                          InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _changePasswordBtn(),
                  ] else ...[
                    _getOtpBtn(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
