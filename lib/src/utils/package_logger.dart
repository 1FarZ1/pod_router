import 'package:logger/logger.dart';

enum FeaturesType {
  auth,
  refresh,
  routing,
  navigation,
  middleware,
  guards,
  general
}

/// Enhanced logger for package operations
class PackageLogger {
  static bool enableDebugLogs = false;

  static final Logger _logger = Logger(
    filter: _PackageLogFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: (DateTime time) => time.toIso8601String(),
    ),
  );

  static const String _packageName = 'pod_router';

  /// Log debug message
  static void debug(dynamic message,
      {FeaturesType featureType = FeaturesType.general}) {
    if (enableDebugLogs) {
      _logger.d(_createMessage(message, featureType: featureType));
    }
  }

  /// Log info message
  static void info(dynamic message,
      {FeaturesType featureType = FeaturesType.general}) {
    _logger.i(_createMessage(message, featureType: featureType));
  }

  /// Log warning message
  static void warning(dynamic message,
      {FeaturesType featureType = FeaturesType.general}) {
    _logger.w(_createMessage(message, featureType: featureType));
  }

  /// Log error message
  static void error(dynamic message,
      {FeaturesType featureType = FeaturesType.general}) {
    _logger.e(_createMessage(message, featureType: featureType));
  }

  /// Create formatted message with feature context
  static String _createMessage(dynamic message,
      {required FeaturesType featureType}) {
    return '[$_packageName][${featureType.name.toUpperCase()}] $message';
  }
}

/// Custom log filter that respects enableDebugLogs setting
class _PackageLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (event.level == Level.debug && !PackageLogger.enableDebugLogs) {
      return false;
    }
    return true;
  }
}
