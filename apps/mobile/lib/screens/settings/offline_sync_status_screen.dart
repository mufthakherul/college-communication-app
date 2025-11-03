import 'package:flutter/material.dart';
import 'package:campus_mesh/services/offline_message_sync_service.dart';
import 'package:campus_mesh/services/local_message_database.dart';
import 'package:campus_mesh/services/connectivity_service.dart';

/// Screen to display offline message sync status and statistics
class OfflineSyncStatusScreen extends StatefulWidget {
  const OfflineSyncStatusScreen({super.key});

  @override
  State<OfflineSyncStatusScreen> createState() =>
      _OfflineSyncStatusScreenState();
}

class _OfflineSyncStatusScreenState extends State<OfflineSyncStatusScreen> {
  final _syncService = OfflineMessageSyncService();
  final _localDb = LocalMessageDatabase();
  final _connectivityService = ConnectivityService();

  bool _isLoading = true;
  bool _isSyncing = false;
  Map<String, int> _syncStats = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final stats = await _syncService.getSyncStatistics();
      setState(() {
        _syncStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load statistics: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _manualSync() async {
    if (!_connectivityService.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot sync: No internet connection'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSyncing = true);

    try {
      await _syncService.syncMessages();
      await _loadStatistics();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Sync Status'),
        actions: [
          if (!_isSyncing)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadStatistics,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Connection Status Card
                  _buildConnectionStatusCard(),
                  const SizedBox(height: 16),

                  // Sync Statistics Card
                  _buildSyncStatisticsCard(),
                  const SizedBox(height: 16),

                  // Manual Sync Button
                  _buildManualSyncButton(),
                  const SizedBox(height: 16),

                  // Info Card
                  _buildInfoCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildConnectionStatusCard() {
    return StreamBuilder<bool>(
      stream: _connectivityService.connectivityStream,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isOnline ? Icons.cloud_done : Icons.cloud_off,
                      color: isOnline ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: isOnline ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            isOnline
                                ? 'Messages will sync automatically'
                                : 'Messages saved locally',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSyncStatisticsCard() {
    final pending = _syncStats['pending'] ?? 0;
    final synced = _syncStats['synced'] ?? 0;
    final failed = _syncStats['failed'] ?? 0;
    final pendingApproval = _syncStats['pending_approval'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Pending Sync',
              pending,
              Icons.schedule,
              Colors.orange,
            ),
            const Divider(),
            _buildStatRow(
              'Pending Approval',
              pendingApproval,
              Icons.hourglass_empty,
              Colors.blue,
            ),
            const Divider(),
            _buildStatRow(
              'Synced',
              synced,
              Icons.done_all,
              Colors.green,
            ),
            const Divider(),
            _buildStatRow(
              'Failed',
              failed,
              Icons.error_outline,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int count, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualSyncButton() {
    return ElevatedButton.icon(
      onPressed: _isSyncing ? null : _manualSync,
      icon: _isSyncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.sync),
      label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'About Offline Sync',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Messages are saved locally when offline\n'
              '• Automatic sync every 5 minutes when online\n'
              '• P2P messages sync directly\n'
              '• Group messages need admin approval\n'
              '• Failed messages retry up to 3 times',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
