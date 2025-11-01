import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:campus_mesh/services/mesh_network_service.dart';
import 'package:campus_mesh/services/permission_service.dart';

/// Screen for mesh network QR code pairing
class MeshQRPairingScreen extends StatefulWidget {
  const MeshQRPairingScreen({super.key});

  @override
  State<MeshQRPairingScreen> createState() => _MeshQRPairingScreenState();
}

class _MeshQRPairingScreenState extends State<MeshQRPairingScreen> {
  final _meshService = MeshNetworkService();
  final _permissionService = PermissionService();
  final MobileScannerController _scannerController = MobileScannerController();
  MeshPairingData? _pairingData;
  bool _isScanning = false;
  bool _isProcessing = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _generateQRCode();
    _checkCameraPermission();
  }

  void _generateQRCode() {
    try {
      final pairingData = _meshService.generatePairingQRCode();
      setState(() {
        _pairingData = pairingData;
      });
    } catch (e) {
      _showMessage('Failed to generate QR code: $e');
    }
  }

  Future<void> _checkCameraPermission() async {
    final hasPermission = await _permissionService.isCameraPermissionGranted();
    if (mounted) {
      setState(() {
        _hasPermission = hasPermission;
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    final granted = await _permissionService.requestCameraPermission();
    if (mounted) {
      setState(() {
        _hasPermission = granted;
      });
      if (granted) {
        setState(() {
          _isScanning = true;
        });
      } else {
        _showMessage('Camera permission is required to scan QR codes');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Pairing'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.qr_code : Icons.qr_code_scanner),
            onPressed: () async {
              if (!_isScanning && !_hasPermission) {
                await _requestCameraPermission();
              } else {
                setState(() {
                  _isScanning = !_isScanning;
                });
              }
            },
            tooltip: _isScanning ? 'Show QR Code' : 'Scan QR Code',
          ),
        ],
      ),
      body: _isScanning ? _buildScanner() : _buildQRDisplay(),
    );
  }

  Widget _buildQRDisplay() {
    if (_pairingData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final expiresIn = _pairingData!.expiresAt?.difference(DateTime.now());
    final minutesLeft = expiresIn?.inMinutes ?? 0;
    final secondsLeft = (expiresIn?.inSeconds ?? 0) % 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Show this QR code to pair',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Scan this code with the other device to establish a secure connection',
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
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: _pairingData!.toQRString(),
              version: QrVersions.auto,
              size: 280,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer, size: 20, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Expires in $minutesLeft:${secondsLeft.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This QR code is unique and will expire automatically',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                  textAlign: TextAlign.center,
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
                    'Device Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Device Name', _pairingData!.deviceName),
                  _buildInfoRow(
                    'Supported Connections',
                    _pairingData!.supportedConnections.join(', '),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _generateQRCode,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate New Code'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  if (_isProcessing) return;
                  
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      _handleScannedCode(barcode.rawValue!);
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
        Container(
          padding: const EdgeInsets.all(24),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              if (_isProcessing)
                const CircularProgressIndicator()
              else ...[
                const Text(
                  'Scan QR Code',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Point your camera at the QR code to pair with another device',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isScanning = false;
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScannedCode(String qrCode) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // Process QR code
      final success = await _meshService.pairWithQRCode(qrCode);

      if (mounted) {
        if (success) {
          _showMessage('Successfully paired with device!');
          Navigator.pop(context, true);
        } else {
          _showMessage('Failed to pair. QR code may be invalid or expired.');
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error: $e');
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}
