import 'dart:io';

import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/cache_service.dart';
import 'package:campus_mesh/services/connectivity_service.dart';
import 'package:campus_mesh/services/debug_logger_service.dart';
import 'package:campus_mesh/services/offline_queue_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Debug Console Screen - Only available in debug mode
/// Provides detailed debugging information about the app state
class DebugConsoleScreen extends StatefulWidget {
  const DebugConsoleScreen({super.key});

  @override
  State<DebugConsoleScreen> createState() => _DebugConsoleScreenState();
}

class _DebugConsoleScreenState extends State<DebugConsoleScreen> {
  final _cacheService = CacheService();
  final _offlineQueueService = OfflineQueueService();
  final _connectivityService = ConnectivityService();
  final _authService = AuthService();
  final _debugLogger = DebugLoggerService();

  Map<String, dynamic> _debugInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _loadDebugInfo();
    }
  }

  Future<void> _loadDebugInfo() async {
    setState(() => _isLoading = true);

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();

      var deviceData = <String, dynamic>{};
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          'platform': 'Android',
          'version': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt.toString(),
          'manufacturer': androidInfo.manufacturer,
          'model': androidInfo.model,
          'device': androidInfo.device,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          'platform': 'iOS',
          'version': iosInfo.systemVersion,
          'name': iosInfo.name,
          'model': iosInfo.model,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      }

      // Get connectivity status
      final isConnected = _connectivityService.isOnline;

      // Get cache stats
      final cacheStats = await _cacheService.getStatistics();

      // Get offline queue stats
      final queueStats = _offlineQueueService.getAnalytics();

      // Get pending actions count
      final pendingActionsCount = _offlineQueueService.pendingActions.length;

      // Get auth status
      await _authService.initialize();
      final isAuthenticated = await _authService.isAuthenticated();
      final currentUserId = _authService.currentUserId;
      final currentUser = currentUserId != null
          ? await _authService.getUserProfile(currentUserId)
          : null;

      // Get debug logger stats
      final loggerStats = _debugLogger.getStatistics();

      setState(() {
        _debugInfo = {
          'app': {
            'name': packageInfo.appName,
            'version': packageInfo.version,
            'buildNumber': packageInfo.buildNumber,
            'packageName': packageInfo.packageName,
          },
          'device': deviceData,
          'connectivity': {
            'status': isConnected ? 'Online' : 'Offline',
            'isConnected': isConnected,
          },
          'auth': {
            'isAuthenticated': isAuthenticated,
            'userId': currentUser?.uid ?? 'N/A',
            'email': currentUser?.email ?? 'N/A',
            'role': currentUser?.role.name ?? 'N/A',
          },
          'cache': cacheStats,
          'offlineQueue': {
            ...queueStats,
            'pendingActions': pendingActionsCount,
          },
          'runtime': {
            'dartVersion': Platform.version,
            'operatingSystem': Platform.operatingSystem,
            'operatingSystemVersion': Platform.operatingSystemVersion,
          },
          'debugLogger': loggerStats,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo = {'error': e.toString()};
        _isLoading = false;
      });
      _debugLogger.error('Error loading debug info', error: e);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyAllInfo() {
    final buffer = StringBuffer()
      ..writeln('=== DEBUG CONSOLE INFO ===')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln();

    _debugInfo.forEach((key, value) {
      buffer.writeln('[$key]');
      if (value is Map) {
        value.forEach((k, v) {
          buffer.writeln('  $k: $v');
        });
      } else {
        buffer.writeln('  $value');
      }
      buffer.writeln();
    });

    buffer
      ..writeln()
      ..writeln(_debugLogger.exportLogs());

    _copyToClipboard(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('Debug Console')),
        body: const Center(
          child: Text('Debug console is only available in debug mode'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadDebugInfo,
          ),
          IconButton(
            icon: const Icon(Icons.copy_all),
            tooltip: 'Copy All Info',
            onPressed: _copyAllInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDebugInfo,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_debugInfo.containsKey('error'))
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SelectableText(
                          'Error: ${_debugInfo['error']}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  else ...[
                    _buildSection('App Information', _debugInfo['app']),
                    _buildSection('Device Information', _debugInfo['device']),
                    _buildSection('Connectivity', _debugInfo['connectivity']),
                    _buildSection('Authentication', _debugInfo['auth']),
                    _buildSection('Cache Statistics', _debugInfo['cache']),
                    _buildSection('Offline Queue', _debugInfo['offlineQueue']),
                    _buildSection('Runtime', _debugInfo['runtime']),
                    _buildSection('Debug Logger', _debugInfo['debugLogger']),
                    _buildLogsSection(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, dynamic data) {
    if (data == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data is Map)
                  ...data.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${entry.key}:',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: SelectableText(
                              '${entry.value}',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            onPressed: () => _copyToClipboard('${entry.value}'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }).toList()
                else
                  SelectableText(data.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsSection() {
    final logs = _debugLogger.getLogs();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            const Text(
              'Debug Logs',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text('${logs.length}'),
              backgroundColor: Colors.blue.shade100,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],
        ),
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: Text('All (${logs.length})'),
                  selected: true,
                  onSelected: (selected) {},
                ),
                for (final level in LogLevel.values)
                  FilterChip(
                    label: Text(
                      '${level.name} (${_debugLogger.getLogsByLevel(level).length})',
                    ),
                    backgroundColor: _getLogLevelColor(
                      level,
                    ).withValues(alpha: 0.2),
                    onSelected: (selected) {},
                  ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: logs.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No logs yet'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          _getLogLevelIcon(log.level),
                          size: 16,
                          color: _getLogLevelColor(log.level),
                        ),
                        title: SelectableText(
                          log.message,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        subtitle: SelectableText(
                          '${log.timestamp.toIso8601String()}${log.tag != null ? ' [${log.tag}]' : ''}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          onPressed: () => _copyToClipboard(log.toString()),
                        ),
                      );
                    },
                  ),
          ),
          if (logs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _copyToClipboard(_debugLogger.exportLogs());
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy All'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(_debugLogger.clearLogs);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear Logs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getLogLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Icons.code;
      case LogLevel.info:
        return Icons.info_outline;
      case LogLevel.warning:
        return Icons.warning_amber;
      case LogLevel.error:
        return Icons.error_outline;
    }
  }

  Color _getLogLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.blue;
      case LogLevel.info:
        return Colors.green;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
    }
  }
}
