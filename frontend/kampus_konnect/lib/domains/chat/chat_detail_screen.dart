// lib/screens/chat_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final int chatId;
  ChatDetailScreen({required this.chatId,});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Details'),
      ),
      body: FutureBuilder(
        future: chatProvider.fetchChat(widget.chatId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: chatProvider.selectedChat['messages'].length,
                    itemBuilder: (ctx, index) {
                      return ListTile(
                        title: Text(chatProvider.selectedChat['messages'][index]
                            ['content']),
                        subtitle: Text(chatProvider.selectedChat['messages']
                            [index]['sender']),
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
                          decoration:
                              InputDecoration(labelText: 'Enter your message'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          final message = _messageController.text;
                          if (message.isNotEmpty) {
                            await chatProvider.sendChat(
                              widget.chatId,
                              chatProvider.selectedChat['sender'],
                              chatProvider.selectedChat['receiver'],
                            
                              message
                            );
                            _messageController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
