import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/usecases/listen_messge.dart';
import '../../../domain/usecases/send_message.dart';
import '../../../domain/usecases/retry_pending_message.dart';
import '../../../domain/usecases/mark_delivered.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ListenMessages listenMessages;
  final SendMessage sendMessageUC;
  final RetryPendingMessages retryPending;
  final MarkDelivered markDelivered;
  final Connectivity connectivity;

  StreamSubscription<List<MessageEntity>>? _messagesSub;

  ChatBloc(
    this.listenMessages,
    this.sendMessageUC,
    this.retryPending,
    this.markDelivered,
    this.connectivity,
  ) : super(const ChatState()) {
    /// 🔵 LOAD & SUBSCRIBE
    on<LoadMessages>(_onLoadMessages);

    /// 🔄 STREAM UPDATES
    on<MessagesUpdated>(_onMessagesUpdated);
    on<MarkDeliveredEvent>(_onMarkDelivered);

    /// 📤 SEND MESSAGE
    on<SendPressed>(_onSendPressed);

    /// 🔁 RETRY PENDING
    on<RetryPendingEvent>(_onRetryPending);

    on<ChatErrorOccurred>((event, emit) {
      emit(state.copyWith(error: event.error, isLoading: false));
    });

    connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        add(RetryPendingEvent());
      }
    });
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    await _messagesSub?.cancel();

    _messagesSub = listenMessages(event.conversationId).listen(
      (messages) => add(MessagesUpdated(messages)),
      onError: (e) => add(ChatErrorOccurred(e.toString())),
    );
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<ChatState> emit) {
    final incoming = event.messages;
    final existing = state.messages;

    final mergedMap = <String, MessageEntity>{};
    for (final m in incoming) {
      mergedMap[m.id] = m;
    }
    for (final m in existing) {
      if (!mergedMap.containsKey(m.id)) {
        mergedMap[m.id] = m;
      }
    }
    final merged = mergedMap.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    emit(state.copyWith(messages: merged, isLoading: false, error: null));
    final myId = Supabase.instance.client.auth.currentUser?.id;
    if (myId != null) {
      final toDeliver = event.messages
          .where((m) => m.userId != myId && m.status != MessageStatus.delivered)
          .toList();
      if (toDeliver.isNotEmpty) {
        add(MarkDeliveredEvent(toDeliver));
      }
    }
  }

  Future<void> _onSendPressed(
    SendPressed event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final result = await connectivity.checkConnectivity();
      final isOnline = result != ConnectivityResult.none;
      final optimistic = MessageEntity(
        id: event.message.id,
        conversationId: event.message.conversationId,
        userId: event.message.userId,
        text: event.message.text,
        createdAt: event.message.createdAt,
        status: isOnline ? MessageStatus.sent : MessageStatus.pending,
      );
      emit(state.copyWith(messages: [...state.messages, optimistic]));
      await sendMessageUC(event.message);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRetryPending(
    RetryPendingEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await retryPending();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onMarkDelivered(
    MarkDeliveredEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      for (final m in event.messages) {
        await markDelivered(m.id);
      }
    } catch (e) {
      // swallow errors to avoid loop; optional logging
    }
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    return super.close();
  }
}
