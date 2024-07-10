import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kampus_konnect/models/app_user_model.dart';
import 'package:kampus_konnect/providers/app_user_provider.dart';
import 'package:kampus_konnect/screens/nav/mainpage.dart';
import 'package:provider/provider.dart';
import '../../services/auth/auth.dart';
import 'change_password.dart';

class EditUserDetailsPage extends StatefulWidget {
  final AppUser user;

  EditUserDetailsPage({required this.user});

  @override
  _EditUserDetailsPageState createState() => _EditUserDetailsPageState();
}

class _EditUserDetailsPageState extends State<EditUserDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  late TextEditingController _addressController;
  late TextEditingController _usernameController;
  late TextEditingController _contactNoController;
  late String? _email;
  late String? _token;

  @override
  void initState() {
    super.initState();
    _fetchCredentials();
    _usernameController = TextEditingController(text: widget.user.username);
    _addressController = TextEditingController(text: widget.user.address);
    _contactNoController = TextEditingController(text: widget.user.contactNo);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _addressController.dispose();
    _contactNoController.dispose();
    super.dispose();
  }

  Future<void> _fetchCredentials() async {
    _email = (await _authService.getEmail());
    _token = (await _authService.getToken());
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      Provider.of<AppUserProvider>(context, listen: false)
          .editUser(
        _email ?? "",
        _token ?? "",
        _usernameController.text,
        _addressController.text,
        _contactNoController.text,
      )
          .then((_) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainPage()));
      });
    }
  }

  Widget _loginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _saveForm();
        },
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(100, 60)),
          backgroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.primaryContainer),
        ),
        child: Text('Save'),
      ),
    );
  }

  Widget _changePasswordBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ChangePasswordPage(email: _email,)),
          );
        },
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(100, 60)),
          backgroundColor: MaterialStateProperty.all<Color>(
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
        title: Text('Edit Post Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactNoController,
                decoration: InputDecoration(labelText: 'Contact No'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a contact number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _loginBtn(),
              _changePasswordBtn(),
            ],
          ),
        ),
      ),
    );
  }
}
