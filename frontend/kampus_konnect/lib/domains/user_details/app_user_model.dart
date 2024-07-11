import '../../main.dart';

class AppUser {
  final String email;
  final String username;
  final int reports;
  final String profilePicPath;
  final String address;
  final String contactNo;

  static String _baseUrl = MyApp.baseUrl;

  AppUser({
    required this.email,
    required this.username,
    required this.reports,
    required this.profilePicPath,
    required this.address,
    required this.contactNo,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      email: json['email'],
      username: json['username'],
      reports: json['reports'],
      address: json['address'],
      contactNo: json['contact_no'],
      profilePicPath: '$_baseUrl/res/${json['email']}_profile_${json['profile_pic_path']}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'reports': reports,
      'address': address,
      'contactNo': contactNo,
      'profilePicPath': profilePicPath,
    };
  }
}