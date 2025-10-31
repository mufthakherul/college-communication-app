import 'package:flutter/material.dart';
import 'package:campus_mesh/services/connectivity_service.dart';
import 'package:campus_mesh/services/offline_queue_service.dart';

/// Banner widget that displays connectivity status and offline queue info
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityService();
    final offlineQueueService = OfflineQueueService();

    return StreamBuilder<bool>(
      stream: connectivityService.connectivityStream,
      initialData: connectivityService.isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        // Don't show banner if online and no queued actions
        if (isOnline && offlineQueueService.pendingActionsCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: isOnline ? Colors.green[700] : Colors.orange[700],
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Icon(
                  isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isOnline ? 'Back online' : 'No internet connection',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!isOnline && offlineQueueService.pendingActionsCount > 0)
                        Text(
                          '${offlineQueueService.pendingActionsCount} action(s) queued',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      if (isOnline && offlineQueueService.pendingActionsCount > 0)
                        Text(
                          'Syncing ${offlineQueueService.pendingActionsCount} action(s)...',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isOnline && offlineQueueService.pendingActionsCount > 0)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
