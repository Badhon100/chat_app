import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/chat/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:chat_app/features/chat/presentation/pages/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/conversation.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  @override
  void initState() {
    super.initState();
    context.read<ConversationBloc>().add(LoadConversations());
  }

  void _showEmailDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Start Chat"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter user email"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ConversationBloc>().add(
                StartConversationByEmail(controller.text.trim()),
              );
            },
            child: const Text("Start"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthStates>(
          listener: (context, state) {
            if (state.user == null) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            }
          },
        ),
        BlocListener<ConversationBloc, ConversationState>(
          listenWhen: (p, c) => c.navigateToChatId != null || c.error != null,
          listener: (context, state) {
            if (state.navigateToChatId != null &&
                state.navigateToChatEmail != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    conversationId: state.navigateToChatId!,
                    otherUserEmail: state.navigateToChatEmail!,
                  ),
                ),
              );
            }
            if (state.error != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Chats"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
          ],
        ),
        body: BlocBuilder<ConversationBloc, ConversationState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.conversations.isEmpty) {
              return const Center(child: Text("No conversations yet"));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.conversations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final Conversation convo = state.conversations[i];

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        convo.otherUserEmail[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      convo.otherUserEmail,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            conversationId: convo.id,
                            otherUserEmail: convo.otherUserEmail,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showEmailDialog,
          child: const Icon(Icons.chat),
        ),
      ),
    );
  }
}
