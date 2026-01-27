import 'dart:developer';

class AppLogger {
  static void info(String message) {
    log('ℹ️ $message', name: 'APP_LOG');
  }

  static void error(String message, [Object? e]) {
    log('❌ $message', name: 'APP_ERROR', error: e);
  }

  static void success(String message) {
    log('✅ $message', name: 'APP_SUCCESS');
  }
}
