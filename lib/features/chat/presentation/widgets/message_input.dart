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
  bool _isListening = false;
  bool _isSpeechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      _isSpeechEnabled = await stt.initialize(
        onError: (val) {
          debugPrint('STT Error: $val');
          if (val.errorMsg == 'error_no_match') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No speech detected. Please try again."),
              ),
            );
          }
          setState(() => _isListening = false);
        },
        onStatus: (val) {
          debugPrint('STT Status: $val');
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
      );
      setState(() {});
    } catch (e) {
      debugPrint("STT Init Error: $e");
    }
  }

  void _toggleListening() async {
    if (!_isSpeechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Speech recognition not available")),
      );
      return;
    }

    if (_isListening) {
      await stt.stop();
      setState(() => _isListening = false);
    } else {
      await stt.listen(
        onResult: (res) {
          setState(() {
            ctrl.text = res.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      );
      setState(() => _isListening = true);
    }
  }

  void _sendMessage() {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;

    if (_isListening) {
      stt.stop();
      setState(() => _isListening = false);
    }

    // Force clear immediately to prevent double sends or UI lag
    ctrl.clear();

    ChatEngineChannel.processMessage(text)
        .then((processed) {
          final processedText = processed.trim();
          if (processedText.isNotEmpty) {
            widget.onSend(processedText);
          }
        })
        .catchError((_) {
          widget.onSend(text);
        });
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
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : Colors.blueAccent,
            ),
            onPressed: _toggleListening,
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
