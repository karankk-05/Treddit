// import 'dart:html'; // Import dart:html for web-specific functionality
// import 'package:campus_ebay/colors_decorations/decorations.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/user.dart';

// class EditDetailsPage extends StatefulWidget {
//   @override
//   _EditDetailsPageState createState() => _EditDetailsPageState();
// }

// class _EditDetailsPageState extends State<EditDetailsPage> {
//   TextEditingController _nameController = TextEditingController();
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _phoneController = TextEditingController();
//   TextEditingController _addressController = TextEditingController();
//   TextEditingController _genderController = TextEditingController();
//   TextEditingController _batchController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController(); // New controller for password field
//   String? _imageUrl; // Variable to store the image URL

//   @override
//   Widget build(BuildContext context) {
//     User user = Provider.of<UserProvider>(context).user;

//     // Initialize text field controllers with existing user details
//     _nameController.text = user.name;
//     _emailController.text = user.email;
//     _phoneController.text = user.phone;
//     _addressController.text = user.address;
//     _genderController.text = user.gender;
//     _batchController.text = user.batch;
// mytext.context=context;
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(left: 10),
//             child: Text('Edit Your Details', style: mytext.headingbold(fontSize: 18)),
//           ),
//           Expanded(child: SizedBox()),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (_imageUrl != null) Image.network(_imageUrl!),
//             Container(
//               width: 160,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(50),
//                 color: Theme.of(context).colorScheme.primaryContainer,
//               ),
//               child: Card(
//                 color: Theme.of(context).colorScheme.primaryContainer,
//                 child: ListTile(
//                   title: Text(
//                     'Pick Image',
//                     style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
//                   ),
//                   onTap: _getImageFromWeb,
//                 ),
//               ),
//             ),
//             SizedBox(height: 14),
//             MyTextField(
//               controller: _nameController,
//               labelText: '  Name',
//             ),
//             SizedBox(height: 14),
//             MyTextField(
//               controller: _emailController,
//               labelText: '  Email',
//             ),
//             SizedBox(height: 14),
//             MyTextField(
//               controller: _phoneController,
//               labelText: '  Phone',
//             ),
//             SizedBox(height: 14),
//             MyTextField(
//               controller: _addressController,
//               labelText: '  Address',
//             ),
//             SizedBox(height: 14),
//             MyTextField(
//               controller: _genderController,
//               labelText: '  Gender',
//             ),
//             SizedBox(height: 14),
//             MyTextField(
//               controller: _batchController,
//               labelText: '  Batch',
//             ),
//             SizedBox(height: 14),
//             MyPasswordField( // New password field
//               controller: _passwordController,
//               labelText: '  Password',
//             ),
//             SizedBox(height: 14),
//             Spacer(),
//             Padding(
//               padding: const EdgeInsets.all(15.0),
//               child: Container(
//                 color: Theme.of(context).colorScheme.background,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     ElevatedButton(
//                       style: ButtonStyle(
//                         maximumSize: MaterialStateProperty.all(Size(115, 80)),
//                         backgroundColor: MaterialStateProperty.all<Color>(
//                           Theme.of(context).colorScheme.primaryContainer,
//                         ),
//                         side: MaterialStateProperty.all<BorderSide>(
//                           BorderSide(color: Colors.white),
//                         ),
//                       ),
//                       onPressed: _saveDetails,
//                       child: Text('Save', style: mytext.headingtext1(fontSize: 18)),
//                     ),
//                     ElevatedButton(
//                       style: ButtonStyle(
//                       maximumSize: MaterialStateProperty.all(Size(115, 80)),
//                         backgroundColor: MaterialStateProperty.all<Color>(
//                           Theme.of(context).colorScheme.primaryContainer,
//                         ),
//                         side: MaterialStateProperty.all<BorderSide>(
//                           BorderSide(color: Colors.white),
//                         ),
//                       ),
//                       onPressed: () {
//                         // Navigate back to the previous screen
//                         Navigator.pop(context);
//                       },
//                       child: Text('Cancel', style: mytext.headingtext1(fontSize: 18)),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Method to pick image from the web
//   void _getImageFromWeb() {
//     // Create an input element
//     FileUploadInputElement uploadInput = FileUploadInputElement();

//     // Trigger a click event on the input element
//     uploadInput.click();

//     // Listen for changes in the input element
//     uploadInput.onChange.listen((event) {
//       final files = uploadInput.files;
//       if (files != null && files.isNotEmpty) {
//         final file = files[0];
//         final reader = FileReader();
//         reader.readAsDataUrl(file);
//         reader.onLoadEnd.listen((loadEndEvent) {
//           final imageUrl = reader.result as String?;
//           // Update the user's image URL in the UserProvider
//           Provider.of<UserProvider>(context, listen: false).updateUser(imageUrl: imageUrl);
//         });
//       }
//     });
//   }

//   // Method to save user details
//   void _saveDetails() {
//     // Update user details
//     Provider.of<UserProvider>(context, listen: false).updateUser(
//       name: _nameController.text,
//       email: _emailController.text,
//       phone: _phoneController.text,
//       address: _addressController.text,
//       gender: _genderController.text,
//       batch: _batchController.text,
//       password: _passwordController.text, // Update password
//       imageUrl: _imageUrl,
//     );
//     // Navigate back to profile page
//     Navigator.pop(context);
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _genderController.dispose();
//     _batchController.dispose();
//     _passwordController.dispose(); // Dispose password controller
//     super.dispose();
//   }
// }

// class MyPasswordField extends StatelessWidget {
//   final TextEditingController controller;
//   final String labelText;

//   const MyPasswordField({
//     required this.controller,
//     required this.labelText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: Theme.of(context).colorScheme.primaryContainer,
//       ),
//       child: TextField(
//         controller: controller,
//         obscureText: true, // Hide password characters
//         style: TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           labelText: labelText,
//           labelStyle: TextStyle(color: Colors.white),
//           border: InputBorder.none,
//         ),
//       ),
//     );
//   }
// }


// class MyTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String labelText;

//   const MyTextField({
//     required this.controller,
//     required this.labelText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: Theme.of(context).colorScheme.primaryContainer,
//       ),
//       child: TextField(
//         controller: controller,
//         style: TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           labelText: labelText,
//           labelStyle: TextStyle(color: Colors.white),
//           border: InputBorder.none,
//         ),
//       ),
//     );
//   }
// }
