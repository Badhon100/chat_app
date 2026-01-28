import '../repositories/chat_repository.dart';

class RetryPendingMessages {
  final ChatRepository repository;

  RetryPendingMessages(this.repository);

  Future<void> call() {
    return repository.retryPending();
  }
}
