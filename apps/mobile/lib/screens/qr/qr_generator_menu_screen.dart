import 'package:campus_mesh/screens/qr/qr_share_screen.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/qr_data_service.dart';
import 'package:flutter/material.dart';

/// Menu screen for generating different types of QR codes
class QRGeneratorMenuScreen extends StatefulWidget {
  const QRGeneratorMenuScreen({super.key});

  @override
  State<QRGeneratorMenuScreen> createState() => _QRGeneratorMenuScreenState();
}

class _QRGeneratorMenuScreenState extends State<QRGeneratorMenuScreen> {
  final _authService = AuthService();

  Future<void> _generateContactInfoQR() async {
    try {
      final user = await _authService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final qrData = QRCodeData(
        type: QRDataType.contactInfo,
        data: {
          'userId': user.uid,
          'name': user.displayName,
          'email': user.email,
          'department': user.department,
          'role': user.role.name,
          'phoneNumber': user.phoneNumber,
        },
        senderId: user.uid,
        senderName: user.displayName,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QRShareScreen(qrData: qrData),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate QR code: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateCustomTextQR() async {
    final textController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Text'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Enter text to encode in QR code',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(textController.text),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final user = await _authService.currentUser;

        final qrData = QRCodeData(
          type: QRDataType.custom,
          data: {'text': result},
          senderId: user?.uid,
          senderName: user?.displayName,
        );

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => QRShareScreen(qrData: qrData),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to generate QR code: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _generateDevicePairingQR() async {
    try {
      final user = await _authService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final qrData = QRCodeData(
        type: QRDataType.devicePairing,
        data: {
          'deviceId': user.uid,
          'deviceName': user.displayName,
          'pairingToken': DateTime.now().millisecondsSinceEpoch.toString(),
        },
        senderId: user.uid,
        senderName: user.displayName,
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QRShareScreen(qrData: qrData),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate QR code: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate QR Code')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Choose what to share',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate a QR code to share information with others',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildOptionCard(
            icon: Icons.person,
            title: 'My Contact Info',
            description: 'Share your name, email, department, and phone number',
            color: Colors.blue,
            onTap: _generateContactInfoQR,
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            icon: Icons.text_fields,
            title: 'Custom Text',
            description: 'Encode any text message in a QR code',
            color: Colors.green,
            onTap: _generateCustomTextQR,
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            icon: Icons.devices,
            title: 'Device Pairing',
            description: 'Generate a code for mesh network pairing',
            color: Colors.orange,
            onTap: _generateDevicePairingQR,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'About QR Codes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• QR codes are app-specific and secure\n'
                  '• Some codes expire after a set time\n'
                  '• Only RPI Communication App can scan these codes\n'
                  '• Never share sensitive passwords via QR codes',
                  style: TextStyle(fontSize: 13, color: Colors.blue.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
