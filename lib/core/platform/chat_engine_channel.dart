import 'package:flutter/services.dart';

class ChatEngineChannel {
  static const _channel = MethodChannel('chat_engine');

  static Future<void> processMessage(String text) async {
    await _channel.invokeMethod('processMessage', {'text': text});
  }
}
