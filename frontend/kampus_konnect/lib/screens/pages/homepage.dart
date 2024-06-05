import 'package:flutter/material.dart';
import '../../services/auth/auth.dart';

class HomePage extends StatelessWidget {
   HomePage({super.key});
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<String?>(
        future: _authService.getEmail(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Text('No email found');
          } else {
            return Text('Email: ${snapshot.data}');
          }
        },
      ),
    );
  }
}