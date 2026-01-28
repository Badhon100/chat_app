import 'package:chat_app/features/chat/domain/entities/conversation.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

class GetConversations {
  final ChatRepository repo;
  GetConversations(this.repo);

  Future<List<Conversation>> call() => repo.getConversations();
}
