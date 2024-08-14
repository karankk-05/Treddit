import 'package:Treddit/domains/auth/widgets/background_page.dart';
import 'package:Treddit/domains/user_details/widgets/profile_detail_field.dart';
import 'package:flutter/material.dart';
import '../../auth/services/auth.dart';
import '../model_provider/app_user_provider.dart';
import 'package:provider/provider.dart';
import '../edit_details/edit_user_details.dart';
import '../widgets/action__buttons.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final email = await _authService.getEmail();
    final token = await _authService.getToken();
    final appUser = Provider.of<AppUserProvider>(context, listen: false);
    if (email != null && token != null) {
      appUser.fetchUser(email, token);
    } else {
      print("User Not Found");
    }
  }

  void _showFullImage(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            backgroundColor: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Image.network(
                imagePath,
                fit: BoxFit.contain,
              ),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appUser = Provider.of<AppUserProvider>(context);
    final user = appUser.appUser;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        )),
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: user == null
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: theme.primaryContainer,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(100),
                            bottomRight: Radius.circular(100),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        child: GestureDetector(
                          onTap: () {
                            if (user.profilePicPath.isNotEmpty) {
                              _showFullImage(user.profilePicPath);
                            }
                          },
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: user.profilePicPath.isNotEmpty
                                ? NetworkImage(user.profilePicPath)
                                : null,
                            child: user.profilePicPath.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.black,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Profile_detail_field(
                            context: context,
                            title: 'Username',
                            detail: user.username,
                            icon: Icons.person),
                        Divider(),
                        Profile_detail_field(
                            context: context,
                            title: 'Email',
                            detail: user.email,
                            icon: Icons.email),
                        Divider(),
                        Profile_detail_field(
                            context: context,
                            title: 'Address',
                            detail: user.address.isNotEmpty
                                ? user.address
                                : 'Add Your Address',
                            icon: Icons.location_on),
                        Divider(),
                        Profile_detail_field(
                            context: context,
                            title: 'Phone Number',
                            detail: user.contactNo.isNotEmpty
                                ? user.contactNo
                                : 'Add Your Phone Number',
                            icon: Icons.phone),
                        const SizedBox(height: 16),
                        Action_Buttons(
                          context: context,
                          label: 'Edit Details',
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  EditUserDetailsPage(user: user),
                            ));
                          },
                        ),
                        const SizedBox(height: 8),
                        Action_Buttons(
                          context: context,
                          label: 'Logout',
                          onTap: () {
                            _authService.logout();
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => BackgroundPage()));
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
