import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<void> call(MessageEntity message) {
    return repository.sendMessage(message);
  }
}
