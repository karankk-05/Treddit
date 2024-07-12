// lib/screens/chat_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final int postId;

  ChatDetailScreen({required this.postId});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  String _receiverEmail = 'keerkaran64@gmail.com';

  @override
  void initState() {
    super.initState();
    Provider.of<ChatProvider>(context, listen: false)
        .fetchMessages(widget.postId);
    print("fecthing messages.");
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    print(chatProvider.messages);
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatProvider.messages.length,
              itemBuilder: (ctx, index) {
                return ListTile(
                  title: Text(
                    chatProvider.messages[index]['chat'],
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'From: ${chatProvider.messages[index]['sender']} To: ${chatProvider.messages[index]['reciever']}',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Message',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty &&
                        _receiverEmail.isNotEmpty) {
                      chatProvider.sendMessage(
                        widget.postId,
                        _receiverEmail,
                        _messageController.text,
                      );
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
