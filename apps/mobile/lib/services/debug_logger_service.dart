// ignore_for_file: cascade_invocations
import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Debug Logger Service - Only active in debug mode
/// Provides centralized logging for debugging purposes
class DebugLoggerService {
  factory DebugLoggerService() => _instance;
  DebugLoggerService._internal();
  static final DebugLoggerService _instance = DebugLoggerService._internal();

  final Queue<LogEntry> _logs = Queue<LogEntry>();
  static const int _maxLogEntries = 500;

  /// Add a debug log entry
  void log(String message, {LogLevel level = LogLevel.info, String? tag}) {
    if (!kDebugMode) return;

    final entry = LogEntry(
      message: message,
      level: level,
      tag: tag,
      timestamp: DateTime.now(),
    );

    _logs.addFirst(entry);
    if (_logs.length > _maxLogEntries) {
      _logs.removeLast();
    }

    // Also print to console
    debugPrint(
      '[${level.name.toUpperCase()}]${tag != null ? ' [$tag]' : ''} $message',
    );
  }

  /// Log info level message
  void info(String message, {String? tag}) {
    log(message, level: LogLevel.info, tag: tag);
  }

  /// Log warning level message
  void warning(String message, {String? tag}) {
    log(message, level: LogLevel.warning, tag: tag);
  }

  /// Log error level message
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (error != null) {
      log('$message: $error', level: LogLevel.error, tag: tag);
    } else {
      log(message, level: LogLevel.error, tag: tag);
    }

    if (stackTrace != null && kDebugMode) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Log debug level message
  void debug(String message, {String? tag}) {
    log(message, level: LogLevel.debug, tag: tag);
  }

  /// Get all logs
  List<LogEntry> getLogs() => List.unmodifiable(_logs);

  /// Get logs filtered by level
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  /// Get logs filtered by tag
  List<LogEntry> getLogsByTag(String tag) {
    return _logs.where((log) => log.tag == tag).toList();
  }

  /// Clear all logs
  void clearLogs() {
    _logs.clear();
  }

  /// Get log statistics
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{
      'totalLogs': _logs.length,
      'maxCapacity': _maxLogEntries,
    };

    // Count by level
    for (final level in LogLevel.values) {
      stats['${level.name}Count'] =
          _logs.where((log) => log.level == level).length;
    }

    // Get unique tags
    final tags =
        _logs.map((log) => log.tag).where((tag) => tag != null).toSet();
    stats['uniqueTags'] = tags.length;

    return stats;
  }

  /// Export logs as string
  String exportLogs() {
    final buffer = StringBuffer();
    buffer.writeln('=== DEBUG LOGS EXPORT ===');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total Entries: ${_logs.length}');
    buffer.writeln();

    for (final log in _logs) {
      buffer.writeln(log.toString());
    }

    return buffer.toString();
  }
}

/// Log entry model
class LogEntry {

  LogEntry({
    required this.message,
    required this.level,
    this.tag,
    required this.timestamp,
  });
  final String message;
  final LogLevel level;
  final String? tag;
  final DateTime timestamp;

  @override
  String toString() {
    final tagStr = tag != null ? '[$tag] ' : '';
    return '[${timestamp.toIso8601String()}] [${level.name.toUpperCase()}] $tagStr$message';
  }
}

/// Log levels
enum LogLevel { debug, info, warning, error }
