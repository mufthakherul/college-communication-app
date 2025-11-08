import 'package:flutter/material.dart';

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
  final List<ScannedDocument> _documents = [];
  final TextEditingController _nameController = TextEditingController();
  bool _isScanning = false;

  void _simulateScan() {
    setState(() => _isScanning = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _documents.add(
            ScannedDocument(
              name: _nameController.text.isEmpty
                  ? 'Document ${_documents.length + 1}'
                  : _nameController.text,
              scanDate: DateTime.now(),
              pages: 1,
              size: '${(2.5 + _documents.length * 0.5).toStringAsFixed(1)} MB',
            ),
          );
          _isScanning = false;
          _nameController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document scanned and saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _deleteDocument(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _documents.removeAt(index));
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Document deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Scanner'), elevation: 0),
      body: Column(
        children: [
          // Scan section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Scan Documents',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Document name (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _simulateScan,
                  icon: _isScanning
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.document_scanner),
                  label: Text(_isScanning ? 'Scanning...' : 'Scan Document'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // Documents list
          Expanded(
            child: _documents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No scanned documents yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan documents to get started',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _documents.length,
                    itemBuilder: (context, index) {
                      final doc = _documents[index];
                      return _buildDocumentCard(doc, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(ScannedDocument doc, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(Icons.description, color: Colors.blue[700], size: 28),
          ),
        ),
        title: Text(
          doc.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${doc.pages} page(s) • ${doc.size}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              'Scanned: ${_formatDate(doc.scanDate)}',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('View'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening ${doc.name}...')),
                );
              },
            ),
            PopupMenuItem(
              child: const Text('Share'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sharing ${doc.name}...')),
                );
              },
            ),
            PopupMenuItem(
              child: const Text('Rename'),
              onTap: () {
                _showRenameDialog(index);
              },
            ),
            PopupMenuItem(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () => _deleteDocument(index),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(int index) {
    final renameController = TextEditingController(
      text: _documents[index].name,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(
          controller: renameController,
          decoration: const InputDecoration(
            hintText: 'New document name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _documents[index].name = renameController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Document renamed')));
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}

class ScannedDocument {
  String name;
  final DateTime scanDate;
  final int pages;
  final String size;

  ScannedDocument({
    required this.name,
    required this.scanDate,
    required this.pages,
    required this.size,
  });
}
