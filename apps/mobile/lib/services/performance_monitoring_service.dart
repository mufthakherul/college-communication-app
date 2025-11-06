import 'package:campus_mesh/services/analytics_service.dart';
import 'package:flutter/foundation.dart';

/// Performance monitoring service for tracking app performance
/// Tracks operation durations and identifies bottlenecks
class PerformanceMonitoringService {
  factory PerformanceMonitoringService() => _instance;
  PerformanceMonitoringService._internal();
  final Map<String, DateTime> _startTimes = {};
  final Map<String, List<int>> _durations = {};
  final AnalyticsService _analytics = AnalyticsService();

  // Singleton pattern
  static final PerformanceMonitoringService _instance =
      PerformanceMonitoringService._internal();

  /// Start tracking a named operation
  void startTrace(String name) {
    _startTimes[name] = DateTime.now();
  }

  /// Stop tracking and record the duration
  Future<void> stopTrace(String name) async {
    if (!_startTimes.containsKey(name)) {
      if (kDebugMode) {
        debugPrint('Warning: No start time found for trace: $name');
      }
      return;
    }

    final duration = DateTime.now().difference(_startTimes[name]!);
    _startTimes.remove(name);

    // Store duration for statistics
    if (!_durations.containsKey(name)) {
      _durations[name] = [];
    }
    _durations[name]!.add(duration.inMilliseconds);

    // Log to analytics
    await _analytics.trackActivity('performance_trace', {
      'name': name,
      'duration_ms': duration.inMilliseconds,
    });

    // Warn about slow operations
    if (duration.inMilliseconds > 1000) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Slow operation: $name took ${duration.inMilliseconds}ms',
        );
      }

      await _analytics.trackActivity('slow_operation', {
        'name': name,
        'duration_ms': duration.inMilliseconds,
      });
    }
  }

  /// Measure a synchronous function
  T measure<T>(String name, T Function() fn) {
    startTrace(name);
    try {
      return fn();
    } finally {
      stopTrace(name);
    }
  }

  /// Measure an asynchronous function
  Future<T> measureAsync<T>(String name, Future<T> Function() fn) async {
    startTrace(name);
    try {
      return await fn();
    } finally {
      await stopTrace(name);
    }
  }

  /// Get average duration for a named operation
  double? getAverageDuration(String name) {
    if (!_durations.containsKey(name) || _durations[name]!.isEmpty) {
      return null;
    }

    final sum = _durations[name]!.reduce((a, b) => a + b);
    return sum / _durations[name]!.length;
  }

  /// Get performance statistics
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{};

    for (final entry in _durations.entries) {
      final name = entry.key;
      final durations = entry.value;

      if (durations.isEmpty) continue;

      durations.sort();
      final sum = durations.reduce((a, b) => a + b);
      final avg = sum / durations.length;
      final min = durations.first;
      final max = durations.last;
      final p95 = durations[(durations.length * 0.95).floor()];

      stats[name] = {
        'count': durations.length,
        'average_ms': avg.toInt(),
        'min_ms': min,
        'max_ms': max,
        'p95_ms': p95,
      };
    }

    return stats;
  }

  /// Clear all performance data
  void clearStatistics() {
    _durations.clear();
    _startTimes.clear();
  }

  /// Log performance statistics
  void logStatistics() {
    if (!kDebugMode) return;

    final stats = getStatistics();
    if (stats.isEmpty) {
      debugPrint('📊 No performance data collected');
      return;
    }

    debugPrint('📊 Performance Statistics:');
    for (final entry in stats.entries) {
      final name = entry.key;
      final data = entry.value as Map<String, dynamic>;
      debugPrint('  $name:');
      debugPrint('    Count: ${data['count']}');
      debugPrint('    Average: ${data['average_ms']}ms');
      debugPrint('    Min: ${data['min_ms']}ms');
      debugPrint('    Max: ${data['max_ms']}ms');
      debugPrint('    P95: ${data['p95_ms']}ms');
    }
  }
}

/// Extension to make performance tracking easier
extension PerformanceTracking on Future {
  /// Wrap a future with performance tracking
  Future<T> traced<T>(String name) async {
    final perf = PerformanceMonitoringService();
    perf.startTrace(name);
    try {
      return await this as T;
    } finally {
      await perf.stopTrace(name);
    }
  }
}
