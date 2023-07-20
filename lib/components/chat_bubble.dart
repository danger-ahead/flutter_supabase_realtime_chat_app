import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble(
      {super.key,
      required this.chat,
      required this.isSender,
      required this.username,
      required this.dateTime});

  final String chat, username, dateTime;
  final bool isSender;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username,
                  style: const TextStyle(fontSize: 10),
                ),
                Text(
                  widget.chat,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: Text(widget.dateTime.substring(11, 16))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
