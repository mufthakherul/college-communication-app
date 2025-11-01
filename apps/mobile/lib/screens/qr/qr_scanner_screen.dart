import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:campus_mesh/services/qr_data_service.dart';
import 'package:campus_mesh/services/mesh_network_service.dart';
import 'package:campus_mesh/services/permission_service.dart';

/// Universal QR scanner screen that handles different QR code types
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final _qrDataService = QRDataService();
  final _meshService = MeshNetworkService();
  final _permissionService = PermissionService();
  final MobileScannerController _controller = MobileScannerController();
  
  bool _isProcessing = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final hasPermission = await _permissionService.isCameraPermissionGranted();
    if (!hasPermission) {
      final granted = await _permissionService.requestCameraPermission();
      if (mounted) {
        setState(() {
          _hasPermission = granted;
        });
      }
      if (!granted && mounted) {
        _showPermissionDeniedDialog();
      }
    } else {
      if (mounted) {
        setState(() {
          _hasPermission = true;
        });
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'Camera permission is required to scan QR codes. Please grant the permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _permissionService.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          if (_hasPermission) ...[
            IconButton(
              icon: const Icon(Icons.flash_on),
              tooltip: 'Toggle Flash',
              onPressed: () => _controller.toggleTorch(),
            ),
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              tooltip: 'Switch Camera',
              onPressed: () => _controller.switchCamera(),
            ),
          ],
        ],
      ),
      body: !_hasPermission
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Camera Permission Required',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'To scan QR codes, please grant camera permission.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _checkCameraPermission,
                      child: const Text('Grant Permission'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: _controller,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            if (barcode.rawValue != null && !_isProcessing) {
                              _handleScannedData(barcode.rawValue!);
                              break;
                            }
                          }
                        },
                      ),
                      Center(
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isProcessing)
                          const CircularProgressIndicator()
                        else ...[
                          Icon(
                            Icons.qr_code_scanner,
                            size: 48,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Point camera at QR code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Works with device pairing, notices, messages, and more',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _handleScannedData(String qrString) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // Try to parse as QR data
      final qrData = _qrDataService.parseQRCode(qrString);

      if (qrData != null) {
        if (qrData.isExpired) {
          _showError('This QR code has expired');
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
          return;
        }

        // Handle based on type
        switch (qrData.type) {
          case QRDataType.devicePairing:
            await _handleDevicePairing(qrString);
            break;
          case QRDataType.noticeShare:
            await _handleNoticeShare(qrData);
            break;
          case QRDataType.messageShare:
            await _handleMessageShare(qrData);
            break;
          case QRDataType.contactInfo:
            await _handleContactInfo(qrData);
            break;
          case QRDataType.fileInfo:
            await _handleFileInfo(qrData);
            break;
          case QRDataType.custom:
            await _handleCustomData(qrData);
            break;
        }
      } else {
        _showError('Invalid QR code format');
      }
    } catch (e) {
      _showError('Failed to process QR code: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handleDevicePairing(String qrString) async {
    try {
      final success = await _meshService.pairWithQRCode(qrString);

      if (success && mounted) {
        Navigator.pop(context, {'success': true, 'type': 'device_pairing'});
        _showSuccess('Device paired successfully!');
      } else {
        _showError('Failed to pair device');
      }
    } catch (e) {
      _showError('Pairing error: $e');
    }
  }

  Future<void> _handleNoticeShare(QRCodeData qrData) async {
    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notice Shared'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              qrData.data['title'] ?? 'Untitled',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              qrData.data['content'] ?? 'No content',
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            if (qrData.senderName != null) ...[
              const SizedBox(height: 12),
              Text(
                'Shared by: ${qrData.senderName}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('View Full Notice'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, {
        'success': true,
        'type': 'notice',
        'data': qrData.data,
      });
    }
  }

  Future<void> _handleMessageShare(QRCodeData qrData) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message Shared'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(qrData.data['content'] ?? 'No content'),
            if (qrData.senderName != null) ...[
              const SizedBox(height: 12),
              Text(
                'From: ${qrData.senderName}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
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

  Future<void> _handleContactInfo(QRCodeData qrData) async {
    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactRow(Icons.person, 'Name', qrData.data['name']),
            _buildContactRow(Icons.email, 'Email', qrData.data['email']),
            if (qrData.data['department'] != null)
              _buildContactRow(
                Icons.business,
                'Department',
                qrData.data['department'],
              ),
            if (qrData.data['role'] != null)
              _buildContactRow(Icons.badge, 'Role', qrData.data['role']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save Contact'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      _showSuccess('Contact saved successfully!');
    }
  }

  Future<void> _handleFileInfo(QRCodeData qrData) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactRow(
              Icons.attach_file,
              'File',
              qrData.data['fileName'],
            ),
            _buildContactRow(Icons.category, 'Type', qrData.data['fileType']),
            _buildContactRow(
              Icons.data_usage,
              'Size',
              _formatFileSize(qrData.data['fileSize'] ?? 0),
            ),
            if (qrData.senderName != null)
              _buildContactRow(Icons.person, 'Shared by', qrData.senderName),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (qrData.data['downloadUrl'] != null)
            ElevatedButton(
              onPressed: () {
                // TODO: Implement download
                Navigator.pop(context);
                _showSuccess('Download started');
              },
              child: const Text('Download'),
            ),
        ],
      ),
    );
  }

  Future<void> _handleCustomData(QRCodeData qrData) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scanned Data'),
        content: Text(qrData.data.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String? value) {
    if (value == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
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

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
