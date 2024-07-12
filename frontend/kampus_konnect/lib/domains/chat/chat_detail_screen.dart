import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final int postId;
  final String reciever;
  final String? sender;

  ChatDetailScreen({
    required this.postId,
    required this.reciever,
    required this.sender,
  });

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the chatProvider if needed
    // Provider.of<ChatProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Details'),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          print(chatProvider.messages);
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (ctx, index) {
                    final message = chatProvider.messages[index];
                    final isSentByUser = message['sender'] == widget.sender;
                    return Align(
                      alignment: isSentByUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: isSentByUser
                              ? Colors.blueAccent
                              : Colors.grey[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: isSentByUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['chat'],
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'From: ${message['sender']}',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              'To: ${message['reciever']}',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.blueAccent),
                      onPressed: () {
                        if (_messageController.text.isNotEmpty &&
                            widget.reciever.isNotEmpty) {
                          chatProvider.sendMessage(
                            widget.postId,
                            widget.reciever,
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
          );
        },
      ),
    );
  }
}
