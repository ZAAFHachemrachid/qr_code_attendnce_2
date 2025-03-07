import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum LogLevel { debug, info, warning, error }

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  late final Directory _logDirectory;
  late final File _logFile;
  bool _initialized = false;

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal();

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Get the application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      _logDirectory = Directory('${appDir.path}/logs');

      // Create logs directory if it doesn't exist
      if (!await _logDirectory.exists()) {
        await _logDirectory.create(recursive: true);
      }

      // Create or open log file
      _logFile = File('${_logDirectory.path}/app.log');
      if (!await _logFile.exists()) {
        await _logFile.create();
      }

      _initialized = true;
    } catch (e) {
      developer.log('Failed to initialize logger: $e', level: 1000);
    }
  }

  Future<void> _writeToFile(String message) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      await _logFile.writeAsString('$message\n', mode: FileMode.append);
    } catch (e) {
      developer.log('Failed to write to log file: $e', level: 1000);
    }
  }

  void _formatAndLog(
    LogLevel level,
    String message,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  ) {
    final timestamp = DateTime.now().toIso8601String();
    final contextStr = context != null ? ' Context: $context' : '';
    final stackStr = stackTrace != null ? '\nStackTrace:\n$stackTrace' : '';

    final formattedMessage =
        '[$timestamp] ${level.name.toUpperCase()}: $message$contextStr$stackStr';

    // Always log to console in debug mode
    developer.log(
      message,
      time: DateTime.now(),
      level: _getLevelValue(level),
      name: 'QR_ATTENDANCE',
      error: context != null ? context.toString() : null,
      stackTrace: stackTrace,
    );

    // Write to file asynchronously
    _writeToFile(formattedMessage);
  }

  int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 0;
      case LogLevel.info:
        return 500;
      case LogLevel.warning:
        return 750;
      case LogLevel.error:
        return 1000;
    }
  }

  void debug(String message, [Map<String, dynamic>? context]) {
    _formatAndLog(LogLevel.debug, message, context, null);
  }

  void info(String message, [Map<String, dynamic>? context]) {
    _formatAndLog(LogLevel.info, message, context, null);
  }

  void warning(String message, [Map<String, dynamic>? context]) {
    _formatAndLog(LogLevel.warning, message, context, null);
  }

  void error(
    String message, [
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  ]) {
    _formatAndLog(LogLevel.error, message, context, stackTrace);
  }
}
