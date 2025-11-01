import 'package:flutter/material.dart';
import 'package:campus_mesh/models/book_model.dart';
import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/services/books_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class BookDetailScreen extends StatefulWidget {
  final BookModel book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _booksService = BooksService();
  final _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  List<BookBorrowModel> _borrowHistory = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadBorrowHistory();
  }

  Future<void> _loadUserProfile() async {
    await _authService.initialize();
    final userId = _authService.currentUserId;
    if (userId != null) {
      final profile = await _authService.getUserProfile(userId);
      if (mounted) {
        setState(() => _currentUser = profile);
      }
    }
  }

  Future<void> _loadBorrowHistory() async {
    final history = await _booksService.getBookBorrowHistory(widget.book.id);
    if (mounted) {
      setState(() => _borrowHistory = history);
    }
  }

  Future<void> _borrowBook() async {
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    final success = await _booksService.borrowBook(
      widget.book.id,
      _currentUser!.uid,
      _currentUser!.displayName,
      _currentUser!.email,
      14, // 14 days borrow period
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book borrowed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to borrow book. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openPDF() async {
    if (widget.book.fileUrl == null) return;

    final url = Uri.parse(widget.book.fileUrl!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    image: widget.book.coverUrl != null
                        ? DecorationImage(
                            image: NetworkImage(widget.book.coverUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.book.coverUrl == null
                      ? const Icon(Icons.book, size: 64, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.book.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.book.author,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(widget.book.category),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.book.categoryDisplayName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            widget.book.isAvailable
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 20,
                            color: widget.book.isAvailable
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.book.isAvailable
                                ? 'Available'
                                : 'Not Available',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: widget.book.isAvailable
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      if (widget.book.isAvailable)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${widget.book.availableCopies}/${widget.book.totalCopies} copies',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            if (widget.book.description.isNotEmpty) ...[
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.book.description,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
            ],

            // Details
            const Text(
              'Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('ISBN', widget.book.isbn),
            _buildDetailRow('Publisher', widget.book.publisher),
            _buildDetailRow('Edition', widget.book.edition),
            _buildDetailRow(
              'Publication Year',
              widget.book.publicationYear > 0
                  ? '${widget.book.publicationYear}'
                  : 'N/A',
            ),
            _buildDetailRow(
              'Department',
              widget.book.department.isNotEmpty
                  ? widget.book.department
                  : 'General',
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                if (widget.book.isAvailable)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _borrowBook,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.book_online),
                      label: const Text('Borrow Book'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (widget.book.fileUrl != null) ...[
                  if (widget.book.isAvailable) const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openPDF,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('View PDF'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Borrow history (for admins/teachers)
            if (_currentUser?.role == UserRole.admin ||
                _currentUser?.role == UserRole.teacher) ...[
              const SizedBox(height: 32),
              const Text(
                'Borrow History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (_borrowHistory.isEmpty)
                const Text(
                  'No borrow history yet',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ..._borrowHistory.map(
                  (borrow) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(borrow.userName[0])),
                      title: Text(borrow.userName),
                      subtitle: Text(
                        'Borrowed: ${_formatDate(borrow.borrowDate)}\n'
                        'Due: ${_formatDate(borrow.dueDate)}\n'
                        'Status: ${borrow.status}',
                      ),
                      isThreeLine: true,
                      trailing: borrow.isOverdue
                          ? Chip(
                              label: Text('${borrow.daysOverdue} days overdue'),
                              backgroundColor: Colors.red[100],
                              labelStyle: const TextStyle(color: Colors.red),
                            )
                          : null,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty || value == 'N/A') return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(BookCategory category) {
    switch (category) {
      case BookCategory.textbook:
        return Colors.blue;
      case BookCategory.reference:
        return Colors.green;
      case BookCategory.fiction:
        return Colors.purple;
      case BookCategory.technical:
        return Colors.orange;
      case BookCategory.research:
        return Colors.teal;
      case BookCategory.magazine:
        return Colors.pink;
      case BookCategory.journal:
        return Colors.indigo;
      case BookCategory.other:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
