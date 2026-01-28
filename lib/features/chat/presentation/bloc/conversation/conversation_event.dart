part of 'conversation_bloc.dart';

abstract class ConversationEvent {}

class LoadConversations extends ConversationEvent {}

class StartConversationByEmail extends ConversationEvent {
  final String email;
  StartConversationByEmail(this.email);
}
