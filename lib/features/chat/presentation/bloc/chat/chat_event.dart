part of 'chat_bloc.dart';

abstract class ChatEvent {}

/// Start listening to a conversation
class LoadMessages extends ChatEvent {
  final String conversationId;
  LoadMessages(this.conversationId);
}

/// Internal event when stream emits
class MessagesUpdated extends ChatEvent {
  final List<MessageEntity> messages;
  MessagesUpdated(this.messages);
}

/// User taps send
class SendPressed extends ChatEvent {
  final MessageEntity message;
  SendPressed(this.message);
}

/// Retry all pending (triggered on connectivity change)
class RetryPendingEvent extends ChatEvent {}

/// Mark incoming messages as delivered
class MarkDeliveredEvent extends ChatEvent {
  final List<MessageEntity> messages;
  MarkDeliveredEvent(this.messages);
}

class ChatErrorOccurred extends ChatEvent {
  final String error;
  ChatErrorOccurred(this.error);
}
