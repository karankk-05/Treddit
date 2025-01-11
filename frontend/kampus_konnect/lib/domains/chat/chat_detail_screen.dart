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
    print("-->${widget.reciever}");
  }

  String convertUtcToIst(String utcTimestamp) {
    DateTime utcDateTime = DateTime.parse(utcTimestamp).toUtc();
    DateTime istDateTime = utcDateTime.toLocal();
    //DateTime istDateTime = utcDateTime.add(Duration(hours: 5, minutes: 30));
    return '${istDateTime.hour.toString().padLeft(2, '0')}:${istDateTime.minute.toString().padLeft(2, '0')}';
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: theme.primaryContainer,
      appBar: AppBar(
        title: Text('Chat Details'),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          final messagesByDate = _groupMessagesByDate(chatProvider.messages);

          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: ListView.builder(
              itemCount: messagesByDate.length,
              itemBuilder: (ctx, index) {
                final date = messagesByDate.keys.elementAt(index);
                final messages = messagesByDate[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Card(
                        color: theme.surfaceContainerHighest,
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            date,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ...messages.map((message) {
                      final isSentByUser = message['sender'] == widget.sender;
                      return Align(
                        alignment: isSentByUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: isSentByUser
                                ? theme.primary
                                : theme.surfaceContainerHighest,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: isSentByUser
                                  ? Radius.circular(10)
                                  : Radius.circular(0),
                              bottomRight: isSentByUser
                                  ? Radius.circular(0)
                                  : Radius.circular(10),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isSentByUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['chat'],
                                style: TextStyle(
                                  color: isSentByUser
                                      ? theme.onSecondary
                                      : theme.onSurface,
                                ),
                              ),
                              Text(
                                '${convertUtcToIst(message['chat_timestamp'])}',
                                style: TextStyle(
                                  color: isSentByUser
                                      ? theme.onSecondary
                                      : theme.onSurface.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          mediaQueryData.viewInsets.left + mediaQueryData.viewPadding.left + 3,
          mediaQueryData.viewInsets.top + mediaQueryData.viewPadding.top,
          mediaQueryData.viewInsets.right + mediaQueryData.viewPadding.right,
          mediaQueryData.viewInsets.bottom +
              mediaQueryData.viewPadding.bottom +
              5,
        ),
        //padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Say Hii...',
                  fillColor: theme.primaryContainer,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: theme.primary),
              onPressed: () {
                if (_messageController.text.isNotEmpty &&
                    widget.reciever.isNotEmpty) {
                  Provider.of<ChatProvider>(context, listen: false).sendMessage(
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
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupMessagesByDate(
      List<Map<String, dynamic>> messages) {
    final messagesByDate = <String, List<Map<String, dynamic>>>{};

    for (final message in messages) {
      final dateTime = DateTime.parse(message['chat_timestamp']).toUtc();
      final date = formatDate(dateTime.add(Duration(hours: 5, minutes: 30)));

      if (!messagesByDate.containsKey(date)) {
        messagesByDate[date] = [];
      }

      messagesByDate[date]!.add(message);
    }

    return messagesByDate;
  }
}
