import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Log levels
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Log entry
class LogEntry {
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String? category;
  final Map<String, dynamic>? metadata;
  final StackTrace? stackTrace;

  LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    this.category,
    this.metadata,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() => {
    'level': level.name,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'category': category,
    'metadata': metadata,
    'stackTrace': stackTrace?.toString(),
  };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
    level: LogLevel.values.byName(json['level']),
    message: json['message'],
    timestamp: DateTime.parse(json['timestamp']),
    category: json['category'],
    metadata: json['metadata'],
    stackTrace: json['stackTrace'] != null 
        ? StackTrace.fromString(json['stackTrace'])
        : null,
  );

  @override
  String toString() {
    final parts = [
      '[${level.name.toUpperCase()}]',
      '[${timestamp.toIso8601String()}]',
      if (category != null) '[$category]',
      message,
    ];
    return parts.join(' ');
  }
}

/// Comprehensive logging service for the app
/// Supports multiple log levels, categories, file logging, and log export
class AppLoggerService {
  static final AppLoggerService _instance = AppLoggerService._internal();
  factory AppLoggerService() => _instance;
  AppLoggerService._internal();

  // In-memory log buffer
  final List<LogEntry> _logs = [];
  static const int _maxLogsInMemory = 1000;
  
  // Configuration
  bool _enabled = true;
  LogLevel _minLevel = kReleaseMode ? LogLevel.info : LogLevel.debug;
  bool _persistLogs = true;
  bool _printToConsole = true;
  
  // File logging
  File? _logFile;
  bool _fileLoggingInitialized = false;

  /// Initialize file logging
  Future<void> initialize() async {
    if (_fileLoggingInitialized) return;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/logs');
      
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }
      
      final fileName = 'app_${DateTime.now().toIso8601String().split('T')[0]}.log';
      _logFile = File('${logsDir.path}/$fileName');
      
      _fileLoggingInitialized = true;
      debugPrint('Log file initialized: ${_logFile!.path}');
    } catch (e) {
      debugPrint('Failed to initialize file logging: $e');
    }
  }

  /// Set whether logging is enabled
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Set minimum log level
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Set whether to persist logs to file
  void setPersistLogs(bool persist) {
    _persistLogs = persist;
  }

  /// Set whether to print to console
  void setPrintToConsole(bool print) {
    _printToConsole = print;
  }

  /// Log a debug message
  void debug(String message, {String? category, Map<String, dynamic>? metadata}) {
    _log(LogLevel.debug, message, category: category, metadata: metadata);
  }

  /// Log an info message
  void info(String message, {String? category, Map<String, dynamic>? metadata}) {
    _log(LogLevel.info, message, category: category, metadata: metadata);
  }

  /// Log a warning message
  void warning(String message, {String? category, Map<String, dynamic>? metadata}) {
    _log(LogLevel.warning, message, category: category, metadata: metadata);
  }

  /// Log an error message
  void error(
    String message, 
    {String? category, 
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace}
  ) {
    final fullMetadata = {...?metadata};
    if (error != null) {
      fullMetadata['error'] = error.toString();
    }
    
    _log(
      LogLevel.error, 
      message, 
      category: category, 
      metadata: fullMetadata,
      stackTrace: stackTrace,
    );
  }

  /// Log a fatal error
  void fatal(
    String message, 
    {String? category, 
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace}
  ) {
    final fullMetadata = {...?metadata};
    if (error != null) {
      fullMetadata['error'] = error.toString();
    }
    
    _log(
      LogLevel.fatal, 
      message, 
      category: category, 
      metadata: fullMetadata,
      stackTrace: stackTrace,
    );
  }

  /// Internal logging method
  void _log(
    LogLevel level,
    String message,
    {String? category,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace}
  ) {
    if (!_enabled) return;
    
    // Check minimum level
    if (level.index < _minLevel.index) return;
    
    final entry = LogEntry(
      level: level,
      message: message,
      timestamp: DateTime.now(),
      category: category,
      metadata: metadata,
      stackTrace: stackTrace,
    );
    
    // Add to memory buffer
    _logs.add(entry);
    if (_logs.length > _maxLogsInMemory) {
      _logs.removeAt(0);
    }
    
    // Print to console if enabled
    if (_printToConsole) {
      if (kDebugMode || level.index >= LogLevel.warning.index) {
        debugPrint(entry.toString());
        if (stackTrace != null) {
          debugPrint(stackTrace.toString());
        }
      }
    }
    
    // Write to file if enabled
    if (_persistLogs && _fileLoggingInitialized) {
      _writeToFile(entry);
    }
  }

  /// Write log entry to file
  Future<void> _writeToFile(LogEntry entry) async {
    if (_logFile == null) return;
    
    try {
      await _logFile!.writeAsString(
        '${entry.toString()}\n',
        mode: FileMode.append,
      );
    } catch (e) {
      debugPrint('Failed to write to log file: $e');
    }
  }

  /// Get all logs
  List<LogEntry> getLogs() => List.unmodifiable(_logs);

  /// Get logs by level
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  /// Get logs by category
  List<LogEntry> getLogsByCategory(String category) {
    return _logs.where((log) => log.category == category).toList();
  }

  /// Get logs in time range
  List<LogEntry> getLogsInRange(DateTime start, DateTime end) {
    return _logs.where((log) => 
      log.timestamp.isAfter(start) && log.timestamp.isBefore(end)
    ).toList();
  }

  /// Get error logs
  List<LogEntry> getErrors() {
    return _logs.where((log) => 
      log.level == LogLevel.error || log.level == LogLevel.fatal
    ).toList();
  }

  /// Get warnings
  List<LogEntry> getWarnings() {
    return _logs.where((log) => log.level == LogLevel.warning).toList();
  }

  /// Clear all logs from memory
  void clearLogs() {
    _logs.clear();
    debugPrint('Cleared all logs from memory');
  }

  /// Clear log file
  Future<void> clearLogFile() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.delete();
      await initialize(); // Recreate file
      debugPrint('Cleared log file');
    }
  }

  /// Export logs as JSON string
  String exportLogsJson() {
    return jsonEncode(_logs.map((log) => log.toJson()).toList());
  }

  /// Export logs to file
  Future<File?> exportLogsToFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportFile = File(
        '${directory.path}/logs_export_${DateTime.now().millisecondsSinceEpoch}.json'
      );
      
      await exportFile.writeAsString(exportLogsJson());
      debugPrint('Exported logs to: ${exportFile.path}');
      return exportFile;
    } catch (e) {
      debugPrint('Failed to export logs: $e');
      return null;
    }
  }

  /// Get log statistics
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{
      'total': _logs.length,
      'byLevel': {},
      'byCategory': {},
    };
    
    // Count by level
    for (final level in LogLevel.values) {
      stats['byLevel'][level.name] = _logs.where((log) => log.level == level).length;
    }
    
    // Count by category
    final categories = _logs.map((log) => log.category).whereType<String>().toSet();
    for (final category in categories) {
      stats['byCategory'][category] = _logs.where((log) => log.category == category).length;
    }
    
    if (_logs.isNotEmpty) {
      stats['oldest'] = _logs.first.timestamp.toIso8601String();
      stats['newest'] = _logs.last.timestamp.toIso8601String();
    }
    
    return stats;
  }

  /// Print log summary
  void printSummary() {
    final stats = getStatistics();
    debugPrint('\n=== Log Summary ===');
    debugPrint('Total Logs: ${stats['total']}');
    debugPrint('By Level:');
    (stats['byLevel'] as Map).forEach((level, count) {
      debugPrint('  $level: $count');
    });
    
    if ((stats['byCategory'] as Map).isNotEmpty) {
      debugPrint('By Category:');
      (stats['byCategory'] as Map).forEach((category, count) {
        debugPrint('  $category: $count');
      });
    }
    
    if (stats.containsKey('oldest')) {
      debugPrint('Time Range: ${stats['oldest']} to ${stats['newest']}');
    }
    debugPrint('==================\n');
  }

  /// Get recent logs (last N entries)
  List<LogEntry> getRecentLogs(int count) {
    if (_logs.length <= count) return List.from(_logs);
    return _logs.sublist(_logs.length - count);
  }

  /// Search logs by message content
  List<LogEntry> searchLogs(String query) {
    final lowerQuery = query.toLowerCase();
    return _logs.where((log) => 
      log.message.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Get log file path
  String? get logFilePath => _logFile?.path;

  /// Check if file logging is available
  bool get isFileLoggingAvailable => _fileLoggingInitialized && _logFile != null;

  /// Rotate log files (create new file for new day)
  Future<void> rotateLogFiles() async {
    if (!_fileLoggingInitialized) return;
    
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (_logFile != null && !_logFile!.path.contains(today)) {
      // Create new log file for today
      await initialize();
      debugPrint('Rotated log file');
    }
  }

  /// Delete old log files (older than N days)
  Future<void> deleteOldLogFiles(int daysToKeep) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/logs');
      
      if (!await logsDir.exists()) return;
      
      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: daysToKeep));
      
      await for (final file in logsDir.list()) {
        if (file is File && file.path.endsWith('.log')) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await file.delete();
            debugPrint('Deleted old log file: ${file.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to delete old log files: $e');
    }
  }
}

// Global logger instance for easy access
final logger = AppLoggerService();
