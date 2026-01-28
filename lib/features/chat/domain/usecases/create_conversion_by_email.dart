import '../repositories/chat_repository.dart';

class CreateConversationByEmail {
  final ChatRepository repository;

  CreateConversationByEmail(this.repository);

  Future<String?> call(String email) {
    return repository.createConversationByEmail(email);
  }
}
