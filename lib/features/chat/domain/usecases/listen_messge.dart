import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class ListenMessages {
  final ChatRepository repo;
  ListenMessages(this.repo);

  Stream<List<MessageEntity>> call(String conversationId) =>
      repo.listenMessages(conversationId);
}
