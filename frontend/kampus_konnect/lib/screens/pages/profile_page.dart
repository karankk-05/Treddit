import 'package:flutter/material.dart';
import '../../services/auth/auth.dart';
import '../../providers/app_user_provider.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final appUser = Provider.of<AppUserProvider>(context);
    final user = appUser.appUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: user == null
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Container(
                  //   width: 200,
                  //   height: 200,
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey[350], // Placeholder color
                  //     borderRadius:
                  //         BorderRadius.circular(100), // Circular shape
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.grey.withOpacity(0.5),
                  //         spreadRadius: 2,
                  //         blurRadius: 5,
                  //         offset: Offset(0, 3), // changes position of shadow
                  //       ),
                  //     ],
                  //   ),
                  //   child: user.profilePicPath != null
                  //       ? ClipOval(
                  //           child: Image.network(
                  //             user.profilePicPath,
                  //             width: 200,
                  //             height: 200,
                  //             fit: BoxFit.cover,
                  //           ),
                  //         )
                  //       : ClipOval(
                  //           child: Image.asset(
                  //             '', // Path to initial image
                  //             width: 200,
                  //             height: 200,
                  //             fit: BoxFit.cover,
                  //           ),
                  //         ),
                  // ),
                  SizedBox(height: 16),
                  ProfileDetailCard2(
                    title: user.username,
                    detail: user.email,
                    size: 24,
                    size2: 18,
                  ),
                  SizedBox(height: 16),
                  ProfileDetailCard(
                    title: 'Address',
                    detail: user.address,
                  ),
                  ProfileDetailCard(
                    title: 'Phone Number',
                    detail: user.contactNo,
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Navigate to Edit Details Page
                      },
                      child: Text(
                        'Edit Details',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ProfileDetailCard extends StatelessWidget {
  final String title;
  final String detail;

  const ProfileDetailCard({
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.5),
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: 8),
            Text(
              detail.isNotEmpty ? detail : 'Add Your $title',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileDetailCard2 extends StatelessWidget {
  final String title;
  final String detail;
  final double size;
  final double size2;

  const ProfileDetailCard2({
    required this.title,
    required this.detail,
    required this.size,
    required this.size2,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.5),
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: 8),
            Text(
              detail != null ? detail : 'Add',
              style: TextStyle(
                fontSize: size2,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
