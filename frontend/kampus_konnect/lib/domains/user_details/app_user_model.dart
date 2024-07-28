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
    String profile_path = json['profile_pic_path'].toString();
    if (profile_path == "null"){
      profile_path = '';
    }else{
      profile_path = '$_baseUrl/res/${json['email']}_profile_${json['profile_pic_path']}';
    }
    return AppUser(
      email: json['email'],
      username: json['username'],
      reports: json['reports'],
      address: json['address'],
      contactNo: json['contact_no'],
      profilePicPath: profile_path,
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
