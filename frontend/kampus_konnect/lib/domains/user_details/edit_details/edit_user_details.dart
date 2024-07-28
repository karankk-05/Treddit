import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kampus_konnect/domains/user_details/app_user_model.dart';
import 'package:kampus_konnect/domains/user_details/app_user_provider.dart';
import 'package:kampus_konnect/nav/nav_bar.dart';
import 'package:provider/provider.dart';
import '../../auth/services/auth.dart';
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
  File? _profileImage;

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

  Future<void> _changeProfilePic() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
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
          .then((_) async {
        if (_profileImage != null) {
          await Provider.of<AppUserProvider>(context, listen: false)
              .updateProfilePic(_email ?? "", _token ?? "", _profileImage!);
        }
        await Provider.of<AppUserProvider>(context, listen: false)
            .fetchUser(_email ?? "", _token ?? "");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainPage(selectedIndex: 3,)));
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
            MaterialPageRoute(
                builder: (context) => ChangePasswordPage(
                      email: _email,
                    )),
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

  Widget _profileImageWidget() {
    return GestureDetector(
      onTap: _changeProfilePic,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _profileImage != null
            ? FileImage(_profileImage!)
            : NetworkImage(widget.user.profilePicPath) as ImageProvider,
        child: _profileImage == null
            ? Icon(
                Icons.camera_alt,
                size: 50,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _profileImageWidget(),
              SizedBox(height: 20),
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
