import '../entities/message_entity.dart';
import '../entities/conversation.dart';

abstract class ChatRepository {
  Stream<List<MessageEntity>> listenMessages(String conversationId);
  Future<void> sendMessage(MessageEntity message);
  Future<void> retryPending();
  Future<List<Conversation>> getConversations();
  Future<String?> createConversationByEmail(String email);
  Future<void> markDelivered(String messageId);
}
