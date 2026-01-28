import 'package:flutter/services.dart';

class ChatEngineChannel {
  static const _channel = MethodChannel('chat_engine');

  static Future<String> processMessage(String text) async {
    final res =
        await _channel.invokeMethod<Map<dynamic, dynamic>>('processMessage', {
      'text': text,
    });
    final map = Map<String, dynamic>.from(res ?? {});
    return map['processed'] ?? text;
  }
}
