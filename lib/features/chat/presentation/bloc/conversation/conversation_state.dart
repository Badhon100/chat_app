part of 'conversation_bloc.dart';

class ConversationState {
  final List<Conversation> conversations;
  final bool loading;
  final String? error;
  final String? navigateToChatId;
  final String? navigateToChatEmail;

  ConversationState({
    this.conversations = const [],
    this.loading = false,
    this.error,
    this.navigateToChatId,
    this.navigateToChatEmail,
  });

  ConversationState copyWith({
    List<Conversation>? conversations,
    bool? loading,
    String? error,
    String? navigateToChatId,
    String? navigateToChatEmail,
  }) {
    return ConversationState(
      conversations: conversations ?? this.conversations,
      loading: loading ?? this.loading,
      error: error,
      navigateToChatId: navigateToChatId,
      navigateToChatEmail: navigateToChatEmail,
    );
  }
}
