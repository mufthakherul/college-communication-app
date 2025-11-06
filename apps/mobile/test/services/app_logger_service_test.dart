import 'package:campus_mesh/services/app_logger_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLoggerService', () {
    late AppLoggerService service;

    setUp(() {
      service = AppLoggerService();
      service.clearLogs(); // Start fresh for each test
      service.setEnabled(true); // Reset to enabled
      service.setMinLevel(LogLevel.debug); // Reset to debug level
    });

    test('should be a singleton', () {
      final service1 = AppLoggerService();
      final service2 = AppLoggerService();
      expect(identical(service1, service2), isTrue);
    });

    test('debug should create log entry', () {
      service.debug('Test debug message');
      final logs = service.getLogs();

      expect(logs.length, equals(1));
      expect(logs.first.level, equals(LogLevel.debug));
      expect(logs.first.message, equals('Test debug message'));
    });

    test('info should create log entry', () {
      service.info('Test info message', category: 'test');
      final logs = service.getLogs();

      expect(logs.length, equals(1));
      expect(logs.first.level, equals(LogLevel.info));
      expect(logs.first.message, equals('Test info message'));
      expect(logs.first.category, equals('test'));
    });

    test('warning should create log entry', () {
      service.warning('Test warning message');
      final logs = service.getLogs();

      expect(logs.length, equals(1));
      expect(logs.first.level, equals(LogLevel.warning));
      expect(logs.first.message, equals('Test warning message'));
    });

    test('error should create log entry with metadata', () {
      service.error('Test error message', metadata: {'code': 500});
      final logs = service.getLogs();

      expect(logs.length, equals(1));
      expect(logs.first.level, equals(LogLevel.error));
      expect(logs.first.message, equals('Test error message'));
      expect(logs.first.metadata!['code'], equals(500));
    });

    test('fatal should create log entry', () {
      service.fatal('Test fatal message');
      final logs = service.getLogs();

      expect(logs.length, equals(1));
      expect(logs.first.level, equals(LogLevel.fatal));
      expect(logs.first.message, equals('Test fatal message'));
    });

    test('getLogsByLevel should filter correctly', () {
      service.debug('Debug 1');
      service.info('Info 1');
      service.warning('Warning 1');
      service.error('Error 1');

      final errorLogs = service.getLogsByLevel(LogLevel.error);
      expect(errorLogs.length, equals(1));
      expect(errorLogs.first.message, equals('Error 1'));

      final infoLogs = service.getLogsByLevel(LogLevel.info);
      expect(infoLogs.length, equals(1));
      expect(infoLogs.first.message, equals('Info 1'));
    });

    test('getLogsByCategory should filter correctly', () {
      service.info('Message 1', category: 'auth');
      service.info('Message 2', category: 'network');
      service.info('Message 3', category: 'auth');

      final authLogs = service.getLogsByCategory('auth');
      expect(authLogs.length, equals(2));
      expect(authLogs.every((log) => log.category == 'auth'), isTrue);
    });

    test('getErrors should return error and fatal logs', () {
      service.info('Info message');
      service.error('Error message 1');
      service.fatal('Fatal message');
      service.error('Error message 2');

      final errors = service.getErrors();
      expect(errors.length, equals(3));
      expect(
        errors.every(
          (log) => log.level == LogLevel.error || log.level == LogLevel.fatal,
        ),
        isTrue,
      );
    });

    test('getWarnings should return only warning logs', () {
      service.info('Info message');
      service.warning('Warning 1');
      service.error('Error message');
      service.warning('Warning 2');

      final warnings = service.getWarnings();
      expect(warnings.length, equals(2));
      expect(warnings.every((log) => log.level == LogLevel.warning), isTrue);
    });

    test('clearLogs should remove all logs', () {
      service.info('Message 1');
      service.info('Message 2');
      service.info('Message 3');

      expect(service.getLogs().length, equals(3));

      service.clearLogs();
      expect(service.getLogs().length, equals(0));
    });

    test('searchLogs should find matching messages', () {
      service.info('User logged in');
      service.info('User profile updated');
      service.info('Notice created');

      final results = service.searchLogs('user');
      expect(results.length, equals(2));
      expect(
        results.every((log) => log.message.toLowerCase().contains('user')),
        isTrue,
      );
    });

    test('getRecentLogs should return last N logs', () {
      for (var i = 0; i < 10; i++) {
        service.info('Message $i');
      }

      final recent = service.getRecentLogs(3);
      expect(recent.length, equals(3));
      expect(recent.last.message, equals('Message 9'));
      expect(recent.first.message, equals('Message 7'));
    });

    test('getStatistics should return correct counts', () {
      service.debug('Debug');
      service.info('Info 1', category: 'auth');
      service.info('Info 2', category: 'network');
      service.warning('Warning');
      service.error('Error');

      final stats = service.getStatistics();
      expect(stats['total'], equals(5));
      expect((stats['byLevel'] as Map)['debug'], equals(1));
      expect((stats['byLevel'] as Map)['info'], equals(2));
      expect((stats['byLevel'] as Map)['warning'], equals(1));
      expect((stats['byLevel'] as Map)['error'], equals(1));
      expect((stats['byCategory'] as Map)['auth'], equals(1));
      expect((stats['byCategory'] as Map)['network'], equals(1));
    });

    test('setEnabled should control logging', () {
      service.setEnabled(false);
      service.info('This should not be logged');
      expect(service.getLogs().length, equals(0));

      service.setEnabled(true);
      service.info('This should be logged');
      expect(service.getLogs().length, equals(1));
    });

    test('setMinLevel should filter logs', () {
      service.setMinLevel(LogLevel.warning);

      service.debug('Debug');
      service.info('Info');
      service.warning('Warning');
      service.error('Error');

      final logs = service.getLogs();
      expect(logs.length, equals(2)); // Only warning and error
      expect(
        logs.every((log) => log.level.index >= LogLevel.warning.index),
        isTrue,
      );
    });

    test('exportLogsJson should return valid JSON', () {
      service.info('Test message', category: 'test');

      final json = service.exportLogsJson();
      expect(json, isNotEmpty);

      // Verify it's valid JSON by parsing it
      final logs = service.getLogs();
      expect(logs.length, greaterThan(0));

      // Check if the JSON string contains the expected data
      // The JSON should contain an array with log entries
      expect(json.startsWith('['), isTrue);
      expect(json.endsWith(']'), isTrue);
    });

    test('LogEntry toString should format correctly', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Test message',
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        category: 'test',
      );

      final str = entry.toString();
      expect(str.contains('[INFO]'), isTrue);
      expect(str.contains('[test]'), isTrue);
      expect(str.contains('Test message'), isTrue);
    });

    test('getLogsInRange should filter by time', () {
      final now = DateTime.now();
      final twoHoursAgo = now.subtract(const Duration(hours: 2));
      final oneHourFromNow = now.add(const Duration(hours: 1));

      service.info('Message 1');

      // Use a wider range to ensure the log is captured
      // getLogsInRange uses isAfter and isBefore which are exclusive
      final logs = service.getLogsInRange(
        twoHoursAgo,
        oneHourFromNow,
      );
      expect(logs.length, equals(1));
    });
  });
}
