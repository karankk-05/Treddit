import 'package:flutter/material.dart';
import 'package:kampus_konnect/screens/auth/login.dart';
import '../../services/auth/auth.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: TextButton(
            child: Text(
              "LOGOUT",
              style: TextStyle(color: Colors.amber),
            ),
            onPressed: () {
              _authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            }));
  }
}
