// // lib/screens/chat_list_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'chat_provider.dart';
// import 'chat_detail_screen.dart';

// class ChatListScreen extends StatelessWidget {
//   final int postId;

//   ChatListScreen({required this.postId});

//   @override
//   Widget build(BuildContext context) {
//     final chatProvider = Provider.of<ChatProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chats', style: TextStyle(color: Colors.white)),
//       ),
//       body: FutureBuilder(
//         future: chatProvider.fetchChatIds(postId),
//         builder: (ctx, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             print('${snapshot.connectionState} we are here');
//             return Center(child: CircularProgressIndicator());
//           } else {
//             print('${snapshot.connectionState} building list = ${chatProvider.chatIds} ');
//             return ListView.builder(
//               itemCount: chatProvider.chatIds.length,
//               itemBuilder: (ctx, index) {
//                 return ListTile(
//                   title: Text(
//                     'Chat ID: ${chatProvider.chatIds[index]}',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   onTap: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (ctx) => ChatDetailScreen(
//                           chatId: chatProvider.chatIds[index],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
