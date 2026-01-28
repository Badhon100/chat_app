import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  final String conversationId;

  MessageModel({
    required String id,
    required String text,
    required String userId,
    required DateTime createdAt,
    required MessageStatus status,
    required this.conversationId,
  }) : super(
         id: id,
         text: text,
         userId: userId,
         createdAt: createdAt,
         status: status,
         conversationId: conversationId,
       );

  /// From Supabase / API
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'],
      text: map['text'] ?? '',
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
      status: _parseStatus(map['status']),
      conversationId: map['conversation_id'],
    );
  }

  /// From domain entity (used when sending)
  factory MessageModel.fromEntity(MessageEntity e) {
    return MessageModel(
      id: e.id,
      text: e.text,
      userId: e.userId,
      createdAt: e.createdAt,
      status: e.status,
      conversationId: e.conversationId,
    );
  }

  /// Convert to Supabase insert map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'conversation_id': conversationId,
    };
  }

  /// Used when marking pending → sent
  MessageModel copyWith({MessageStatus? status}) {
    return MessageModel(
      id: id,
      text: text,
      userId: userId,
      createdAt: createdAt,
      status: status ?? this.status,
      conversationId: conversationId,
    );
  }

  /// 🔥 SAFE STATUS PARSER (fixes your crash earlier too)
  static MessageStatus _parseStatus(dynamic value) {
    if (value == null) return MessageStatus.sent;
    
    // If the server says "pending", it means we (or another device) sent it, 
    // so it is "sent" from the perspective of a fresh fetch.
    // Only local-only messages should be "pending".
    if (value.toString().toLowerCase() == 'pending') {
      return MessageStatus.sent;
    }

    try {
      return MessageStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      );
    } catch (_) {
      return MessageStatus.sent;
    }
  }
}
