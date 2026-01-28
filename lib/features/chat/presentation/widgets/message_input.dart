import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:chat_app/core/platform/chat_engine_channel.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  const MessageInput({super.key, required this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final ctrl = TextEditingController();
  final stt = SpeechToText();

  void startListening() async {
    await stt.initialize();
    stt.listen(
      onResult: (res) {
        setState(() => ctrl.text = res.recognizedWords);
      },
    );
  }

  void _sendMessage() {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;

    ChatEngineChannel.processMessage(text).then((processed) {
      final processedText = processed.trim();
      if (processedText.isNotEmpty) {
        widget.onSend(processedText);
      }
    }).catchError((_) {
      widget.onSend(text);
    });

    ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.blueAccent),
            onPressed: startListening,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
