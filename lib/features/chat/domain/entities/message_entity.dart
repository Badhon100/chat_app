enum MessageStatus { pending, sent, delivered }

class MessageEntity {
  final String id;
  final String conversationId;
  final String userId;
  final String text;
  final DateTime createdAt;
  final MessageStatus status;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.status,
  });
}
