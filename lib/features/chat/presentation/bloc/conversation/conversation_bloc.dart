import 'package:chat_app/features/chat/domain/entities/conversation.dart';
import 'package:chat_app/features/chat/domain/usecases/create_conversion_by_email.dart';
import 'package:chat_app/features/chat/domain/usecases/get_conversation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final GetConversations getConversations;
  final CreateConversationByEmail createConversation;

  ConversationBloc(this.getConversations, this.createConversation)
    : super(ConversationState()) {
    on<LoadConversations>(_onLoad);
    on<StartConversationByEmail>(_onStartByEmail);
  }

  Future<void> _onLoad(
    LoadConversations event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    final list = await getConversations();
    emit(state.copyWith(conversations: list, loading: false));
  }

  Future<void> _onStartByEmail(
    StartConversationByEmail event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final id = await createConversation(event.email);

      if (id == null) {
        emit(state.copyWith(loading: false, error: "User not found"));
      } else {
        emit(
          state.copyWith(
            loading: false,
            navigateToChatId: id,
            navigateToChatEmail: event.email,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(loading: false, error: "Error: $e"));
    }
  }
}
