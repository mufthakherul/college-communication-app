import 'package:flutter/material.dart';

import 'package:campus_mesh/services/cache_service.dart';
import 'package:campus_mesh/services/conflict_resolution_service.dart';
import 'package:campus_mesh/services/connectivity_service.dart';
import 'package:campus_mesh/services/local_message_database.dart';
import 'package:campus_mesh/services/local_notice_database.dart';
import 'package:campus_mesh/services/offline_queue_service.dart';

/// Screen for sync and network settings
class SyncSettingsScreen extends StatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  State<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends State<SyncSettingsScreen> {
  final _offlineQueueService = OfflineQueueService();
  final _connectivityService = ConnectivityService();
  final _cacheService = CacheService();
  final _conflictService = ConflictResolutionService();

  bool _isProcessing = false;
  Map<String, dynamic> _queueAnalytics = {};
  Map<String, dynamic> _cacheStats = {};
  Map<String, dynamic> _conflictStats = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final queueAnalytics = _offlineQueueService.getAnalytics();
    final cacheStats = await _cacheService.getStatistics();
    final conflictStats = _conflictService.getStatistics();

    setState(() {
      _queueAnalytics = queueAnalytics;
      _cacheStats = cacheStats;
      _conflictStats = conflictStats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Settings')),
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildNetworkSection(),
            const SizedBox(height: 24),
            _buildQueueSection(),
            const SizedBox(height: 24),
            _buildCacheSection(),
            const SizedBox(height: 24),
            _buildConflictSection(),
            const SizedBox(height: 24),
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkSection() {
    final isOnline = _connectivityService.isOnline;
    final quality = _connectivityService.networkQuality;
    final lastSync = _connectivityService.getLastSyncTimeText();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Network Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Connection',
              isOnline ? 'Online' : 'Offline',
              icon: isOnline ? Icons.cloud_done : Icons.cloud_off,
              iconColor: isOnline ? Colors.green : Colors.red,
            ),
            _buildInfoRow(
              'Quality',
              _connectivityService.getNetworkQualityText(),
              icon: _getQualityIcon(quality),
              iconColor: _getQualityColor(quality),
            ),
            _buildInfoRow('Last Sync', lastSync, icon: Icons.sync),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueSection() {
    final pendingCount = (_queueAnalytics['queueSize'] as int?) ?? 0;
    final totalSynced = (_queueAnalytics['totalSynced'] as int?) ?? 0;
    final totalFailed = (_queueAnalytics['totalFailed'] as int?) ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Offline Queue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Pending Actions',
              pendingCount.toString(),
              icon: Icons.queue,
              iconColor: pendingCount > 0 ? Colors.orange : Colors.green,
            ),
            _buildInfoRow(
              'Synced',
              totalSynced.toString(),
              icon: Icons.check_circle,
              iconColor: Colors.green,
            ),
            _buildInfoRow(
              'Failed',
              totalFailed.toString(),
              icon: Icons.error,
              iconColor: totalFailed > 0 ? Colors.red : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheSection() {
    final sizeMB = ((_cacheStats['totalSizeMB'] as num?) ?? 0.0)
        .toStringAsFixed(2);
    final usagePercent = ((_cacheStats['usagePercent'] as num?) ?? 0.0)
        .toStringAsFixed(1);
    final diskSize = (_cacheStats['diskCacheSize'] as int?) ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cache',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Cache Size', '$sizeMB MB', icon: Icons.storage),
            _buildInfoRow('Usage', '$usagePercent%', icon: Icons.pie_chart),
            _buildInfoRow(
              'Cached Items',
              diskSize.toString(),
              icon: Icons.folder,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (double.tryParse(usagePercent) ?? 0) / 100,
              backgroundColor: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictSection() {
    final unresolvedCount = (_conflictStats['unresolvedCount'] as int?) ?? 0;
    final strategy =
        (_conflictStats['defaultStrategy'] as String?) ?? 'unknown';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conflict Resolution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Unresolved Conflicts',
              unresolvedCount.toString(),
              icon: Icons.warning,
              iconColor: unresolvedCount > 0 ? Colors.orange : Colors.green,
            ),
            _buildInfoRow(
              'Strategy',
              _formatStrategyName(strategy),
              icon: Icons.settings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _syncNow,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(_isProcessing ? 'Syncing...' : 'Sync Now'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearCache,
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Clear Cache'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearQueue,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Queue'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearLocalMessages,
                icon: const Icon(Icons.message),
                label: const Text('Clear Local Messages'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearLocalNotices,
                icon: const Icon(Icons.announcement),
                label: const Text('Clear Local Notices'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await _clearLocalMessages(confirm: false);
                  await _clearLocalNotices(confirm: false);
                  await _clearCache();
                },
                icon: const Icon(Icons.cleaning_services),
                label: const Text('Clear All Offline Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: iconColor ?? Colors.grey),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _getQualityIcon(NetworkQuality quality) {
    switch (quality) {
      case NetworkQuality.excellent:
        return Icons.signal_cellular_alt;
      case NetworkQuality.good:
        return Icons.signal_cellular_alt_2_bar;
      case NetworkQuality.poor:
        return Icons.signal_cellular_alt_1_bar;
      case NetworkQuality.offline:
        return Icons.signal_cellular_off;
    }
  }

  Color _getQualityColor(NetworkQuality quality) {
    switch (quality) {
      case NetworkQuality.excellent:
        return Colors.green;
      case NetworkQuality.good:
        return Colors.blue;
      case NetworkQuality.poor:
        return Colors.orange;
      case NetworkQuality.offline:
        return Colors.red;
    }
  }

  String _formatStrategyName(String strategy) {
    return strategy
        .replaceAllMapped(RegExp('([A-Z])'), (match) => ' ${match.group(0)}')
        .trim();
  }

  Future<void> _syncNow() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      if (!_connectivityService.isOnline) {
        _showMessage('Cannot sync: device is offline');
        return;
      }

      await _offlineQueueService.processQueue();
      await _loadStatistics();
      _showMessage('Sync completed successfully');
    } catch (e) {
      _showMessage('Sync failed: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await _showConfirmDialog(
      'Clear Cache',
      'Are you sure you want to clear all cached data? This will require re-downloading data.',
    );

    if (confirmed ?? false) {
      try {
        await _cacheService.clear();
        await _loadStatistics();
        _showMessage('Cache cleared successfully');
      } catch (e) {
        _showMessage('Failed to clear cache: $e');
      }
    }
  }

  Future<void> _clearLocalMessages({bool confirm = true}) async {
    bool proceed = true;
    if (confirm) {
      final confirmed = await _showConfirmDialog(
        'Clear Local Messages',
        'This will delete locally stored unsent/synced messages (does not delete server messages). Proceed?',
      );
      proceed = confirmed ?? false;
    }

    if (!proceed) return;

    try {
      final db = LocalMessageDatabase();
      final count = await (await db.database).delete('local_messages');
      await _loadStatistics();
      _showMessage('Cleared $count local messages');
    } catch (e) {
      _showMessage('Failed to clear local messages: $e');
    }
  }

  Future<void> _clearLocalNotices({bool confirm = true}) async {
    bool proceed = true;
    if (confirm) {
      final confirmed = await _showConfirmDialog(
        'Clear Local Notices',
        'This will delete cached notices stored on device. Proceed?',
      );
      proceed = confirmed ?? false;
    }

    if (!proceed) return;

    try {
      final db = LocalNoticeDatabase();
      final count = await db.clearAll();
      await _loadStatistics();
      _showMessage('Cleared $count local notices');
    } catch (e) {
      _showMessage('Failed to clear local notices: $e');
    }
  }

  Future<void> _clearQueue() async {
    final confirmed = await _showConfirmDialog(
      'Clear Queue',
      'Are you sure you want to clear all pending actions? This cannot be undone.',
    );

    if (confirmed ?? false) {
      try {
        await _offlineQueueService.clearQueue();
        await _loadStatistics();
        _showMessage('Queue cleared successfully');
      } catch (e) {
        _showMessage('Failed to clear queue: $e');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
