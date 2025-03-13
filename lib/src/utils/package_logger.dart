/// Simple logger for package operations
class PackageLogger {
  static bool enableDebugLogs = false;

  /// Log debug message
  static void debug(String message) {
    if (enableDebugLogs) {
      print('[GoRiverpodRouter] DEBUG: $message');
    }
  }

  /// Log info message
  static void info(String message) {
    print('[GoRiverpodRouter] INFO: $message');
  }

  /// Log error message
  static void error(String message) {
    print('[GoRiverpodRouter] ERROR: $message');
  }
}
