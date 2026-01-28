import '../repositories/chat_repository.dart';

class MarkDelivered {
  final ChatRepository repository;

  MarkDelivered(this.repository);

  Future<void> call(String messageId) {
    return repository.markDelivered(messageId);
  }
}
