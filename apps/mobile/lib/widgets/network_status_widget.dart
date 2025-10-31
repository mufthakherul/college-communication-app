import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

/// Widget to display network status and quality
class NetworkStatusWidget extends StatefulWidget {
  const NetworkStatusWidget({super.key});

  @override
  State<NetworkStatusWidget> createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget> {
  final _connectivityService = ConnectivityService();
  bool _isOnline = true;
  NetworkQuality _quality = NetworkQuality.good;

  @override
  void initState() {
    super.initState();
    _isOnline = _connectivityService.isOnline;
    _quality = _connectivityService.networkQuality;

    // Listen for connectivity changes
    _connectivityService.connectivityStream.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });

    // Listen for quality changes
    _connectivityService.networkQualityStream.listen((quality) {
      if (mounted) {
        setState(() {
          _quality = quality;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnline && _quality != NetworkQuality.poor) {
      // Don't show anything if connection is good
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _getBackgroundColor(),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getMessage(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          if (!_isOnline)
            TextButton(
              onPressed: () {
                // Trigger sync attempt
                _showSyncDialog(context);
              },
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!_isOnline) {
      return Colors.red.shade700;
    } else if (_quality == NetworkQuality.poor) {
      return Colors.orange.shade700;
    }
    return Colors.grey.shade700;
  }

  IconData _getIcon() {
    if (!_isOnline) {
      return Icons.cloud_off;
    } else if (_quality == NetworkQuality.poor) {
      return Icons.signal_cellular_alt_1_bar;
    }
    return Icons.signal_cellular_alt;
  }

  String _getMessage() {
    if (!_isOnline) {
      return 'You are offline. Changes will sync when online.';
    } else if (_quality == NetworkQuality.poor) {
      return 'Poor connection. Some features may be slow.';
    }
    return 'Connection restored';
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline Mode'),
        content: const Text(
          'You are currently offline. Your changes are being saved and will sync automatically when you reconnect to the internet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
