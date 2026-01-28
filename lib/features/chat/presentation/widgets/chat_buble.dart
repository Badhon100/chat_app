import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(12),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _buildStatusText(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText() {
    final timeStr = "${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}";
    
    if (!isMe) {
      return Text(
        timeStr,
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      );
    }

    String statusText = "";
    Color statusColor = Colors.grey;

    switch (message.status) {
      case MessageStatus.pending:
        statusText = "Pending";
        break;
      case MessageStatus.sent:
        statusText = "Sent";
        break;
      case MessageStatus.delivered:
        statusText = "Delivered";
        statusColor = Colors.green;
        break;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          timeStr,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(width: 4),
        Text(
          statusText,
          style: TextStyle(fontSize: 10, color: statusColor),
        ),
      ],
    );
  }
}
