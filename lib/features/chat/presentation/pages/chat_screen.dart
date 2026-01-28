import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:chat_app/features/chat/presentation/widgets/chat_buble.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserEmail;
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadMessages(widget.conversationId));
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.otherUserEmail)),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (_, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.messages.isEmpty) {
                    return const Center(child: Text("No messages yet"));
                  }
                  final messages = state.messages.reversed.toList();
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg = messages[i];
                      return MessageBubble(
                        message: msg,
                        isMe: msg.userId == userId,
                      );
                    },
                  );
                },
              ),
            ),
            MessageInput(
              onSend: (text) {
                final msg = MessageEntity(
                  id: const Uuid().v4(),
                  conversationId: widget.conversationId,
                  userId: userId,
                  text: text,
                  createdAt: DateTime.now(),
                  status: MessageStatus.pending,
                );
                context.read<ChatBloc>().add(SendPressed(msg));
              },
            ),
          ],
        ),
      ),
    );
  }
}
