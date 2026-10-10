import 'package:flutter/foundation.dart';

/// Lightweight, Safe Logging Utility for Debug and Error Tracking
class AppLogger {
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '[INFO]';
      debugPrint('$prefix $message');
    }
  }

  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag ⚠️]' : '[WARN ⚠️]';
      debugPrint('$prefix $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace, String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag ❌]' : '[ERROR ❌]';
      debugPrint('$prefix $message');
      if (error != null) debugPrint('Details: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }
}
