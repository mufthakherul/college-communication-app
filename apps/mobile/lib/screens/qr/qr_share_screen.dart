import 'package:campus_mesh/services/qr_data_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Screen for generating QR codes to share data
class QRShareScreen extends StatelessWidget {
  const QRShareScreen({super.key, required this.qrData});
  final QRCodeData qrData;

  @override
  Widget build(BuildContext context) {
    final hasExpiry = qrData.expiresAt != null;
    final expiresIn =
        hasExpiry ? qrData.expiresAt!.difference(DateTime.now()) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share via QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _getIconForType(qrData.type),
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Share ${qrData.getDescription()}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Others can scan this code with the app to view the content',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData.toQRString(),
                version: QrVersions.auto,
                size: 280,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            ),
            const SizedBox(height: 24),
            if (hasExpiry && expiresIn != null && !qrData.isExpired)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer, size: 20, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Expires in ${_formatDuration(expiresIn)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              )
            else if (hasExpiry && qrData.isExpired)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 20,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'This QR code has expired',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shared Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoContent(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        size: 20,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'App-Specific QR Code',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This QR code can only be scanned and read within the RPI Communication App',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoContent() {
    switch (qrData.type) {
      case QRDataType.noticeShare:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Title', qrData.data['title'] ?? 'N/A'),
            _buildInfoRow('Type', qrData.data['noticeType'] ?? 'N/A'),
            if (qrData.senderName != null)
              _buildInfoRow('Shared by', qrData.senderName!),
          ],
        );
      case QRDataType.messageShare:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Message', qrData.data['content'] ?? 'N/A'),
            if (qrData.senderName != null)
              _buildInfoRow('From', qrData.senderName!),
          ],
        );
      case QRDataType.contactInfo:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', qrData.data['name'] ?? 'N/A'),
            _buildInfoRow('Email', qrData.data['email'] ?? 'N/A'),
            if (qrData.data['department'] != null)
              _buildInfoRow('Department', qrData.data['department']),
            if (qrData.data['role'] != null)
              _buildInfoRow('Role', qrData.data['role']),
          ],
        );
      case QRDataType.fileInfo:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('File', qrData.data['fileName'] ?? 'N/A'),
            _buildInfoRow('Type', qrData.data['fileType'] ?? 'N/A'),
            _buildInfoRow(
              'Size',
              _formatFileSize(qrData.data['fileSize'] ?? 0),
            ),
            if (qrData.senderName != null)
              _buildInfoRow('Shared by', qrData.senderName!),
          ],
        );
      case QRDataType.devicePairing:
        return const Text('Device pairing information');
      case QRDataType.custom:
        return const Text('Custom data');
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(QRDataType type) {
    switch (type) {
      case QRDataType.noticeShare:
        return Icons.campaign;
      case QRDataType.messageShare:
        return Icons.message;
      case QRDataType.contactInfo:
        return Icons.person;
      case QRDataType.fileInfo:
        return Icons.attach_file;
      case QRDataType.devicePairing:
        return Icons.devices;
      case QRDataType.custom:
        return Icons.qr_code;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return '${duration.inSeconds}s';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes}m';
    } else if (duration.inDays < 1) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inDays}d';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About QR Sharing'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This QR code contains information that can be shared with other students.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'How to use:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '1. Show this QR code to another student\n'
                '2. They scan it using the app\'s QR scanner\n'
                '3. The information is shared instantly',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text('Security:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                '• QR codes are app-specific\n'
                '• Standard QR readers cannot decode them\n'
                '• Some codes expire automatically\n'
                '• Only works within the RPI app',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
