import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:campus_mesh/models/book_model.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/appwrite_config.dart';

class BooksService {
  final _appwrite = AppwriteService();
  final _authService = AuthService();

  StreamController<List<BookModel>>? _booksController;
  Timer? _pollingTimer;

  // Get current user ID
  String? get _currentUserId => _authService.currentUserId;

  // Get all books (polling-based stream)
  Stream<List<BookModel>> getBooks() {
    _booksController ??= StreamController<List<BookModel>>.broadcast(
      onListen: () => _startPolling(),
      onCancel: () => _stopPolling(),
    );
    return _booksController!.stream;
  }

  void _startPolling() {
    _fetchBooks(); // Fetch immediately
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchBooks(),
    );
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchBooks() async {
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.booksCollectionId,
        queries: [Query.orderDesc('created_at'), Query.limit(100)],
      );

      final books =
          docs.documents.map((doc) => BookModel.fromJson(doc.data)).toList();

      _booksController?.add(books);
    } catch (e) {
      debugPrint('Error fetching books: $e');
      _booksController?.addError(e);
    }
  }

  // Get books by category
  Future<List<BookModel>> getBooksByCategory(BookCategory category) async {
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.booksCollectionId,
        queries: [
          Query.equal('category', category.name),
          Query.orderDesc('created_at'),
          Query.limit(100),
        ],
      );

      return docs.documents.map((doc) => BookModel.fromJson(doc.data)).toList();
    } catch (e) {
      debugPrint('Error fetching books by category: $e');
      return [];
    }
  }

  // Get books by department
  Future<List<BookModel>> getBooksByDepartment(String department) async {
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.booksCollectionId,
        queries: [
          Query.equal('department', department),
          Query.orderDesc('created_at'),
          Query.limit(100),
        ],
      );

      return docs.documents.map((doc) => BookModel.fromJson(doc.data)).toList();
    } catch (e) {
      debugPrint('Error fetching books by department: $e');
      return [];
    }
  }

  // Search books by title or author
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      // Search by title
      final titleDocs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.booksCollectionId,
        queries: [Query.search('title', query), Query.limit(50)],
      );

      // Search by author
      final authorDocs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.booksCollectionId,
        queries: [Query.search('author', query), Query.limit(50)],
      );

      // Combine and deduplicate results
      final allDocs = {...titleDocs.documents, ...authorDocs.documents};
      return allDocs.map((doc) => BookModel.fromJson(doc.data)).toList();
    } catch (e) {
      debugPrint('Error searching books: $e');
      return [];
    }
  }

  // Get single book details
  Future<BookModel?> getBook(String bookId) async {
    try {
      final doc = await _appwrite.databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.booksCollectionId,
        documentId: bookId,
      );

      return BookModel.fromJson(doc.data);
    } catch (e) {
      debugPrint('Error fetching book: $e');
      return null;
    }
  }

  // Create a new book (admin/teacher only)
  Future<BookModel?> createBook(BookModel book) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.booksCollectionId,
        documentId: ID.unique(),
        data: book.toJson(),
      );

      // Refresh the books list
      _fetchBooks();

      return BookModel.fromJson(doc.data);
    } catch (e) {
      debugPrint('Error creating book: $e');
      return null;
    }
  }

  // Update a book (admin/teacher only)
  Future<bool> updateBook(String bookId, Map<String, dynamic> updates) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.booksCollectionId,
        documentId: bookId,
        data: updates,
      );

      // Refresh the books list
      _fetchBooks();

      return true;
    } catch (e) {
      debugPrint('Error updating book: $e');
      return false;
    }
  }

  // Delete a book (admin only)
  Future<bool> deleteBook(String bookId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _appwrite.databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.booksCollectionId,
        documentId: bookId,
      );

      // Refresh the books list
      _fetchBooks();

      return true;
    } catch (e) {
      debugPrint('Error deleting book: $e');
      return false;
    }
  }

  // Borrow a book
  Future<bool> borrowBook(
    String bookId,
    String userId,
    String userName,
    String userEmail,
    int daysToReturn,
  ) async {
    try {
      final book = await getBook(bookId);
      if (book == null || !book.isAvailable) {
        return false;
      }

      // Create borrow record
      final borrowRecord = BookBorrowModel(
        id: ID.unique(),
        bookId: bookId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        borrowDate: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: daysToReturn)),
        status: 'borrowed',
      );

      await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.bookBorrowsCollectionId,
        documentId: borrowRecord.id,
        data: borrowRecord.toJson(),
      );

      // Update book availability
      await updateBook(bookId, {
        'available_copies': book.availableCopies - 1,
        'status': book.availableCopies - 1 <= 0 ? 'borrowed' : book.status.name,
      });

      return true;
    } catch (e) {
      debugPrint('Error borrowing book: $e');
      return false;
    }
  }

  // Return a book
  Future<bool> returnBook(String borrowId, String bookId) async {
    try {
      final book = await getBook(bookId);
      if (book == null) return false;

      // Update borrow record
      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.bookBorrowsCollectionId,
        documentId: borrowId,
        data: {
          'return_date': DateTime.now().toIso8601String(),
          'status': 'returned',
        },
      );

      // Update book availability
      await updateBook(bookId, {
        'available_copies': book.availableCopies + 1,
        'status': 'available',
      });

      return true;
    } catch (e) {
      debugPrint('Error returning book: $e');
      return false;
    }
  }

  // Get user's borrowed books
  Future<List<BookBorrowModel>> getUserBorrowedBooks(String userId) async {
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.bookBorrowsCollectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.equal('status', 'borrowed'),
          Query.orderDesc('borrow_date'),
        ],
      );

      return docs.documents
          .map((doc) => BookBorrowModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching borrowed books: $e');
      return [];
    }
  }

  // Get all borrow records for a book
  Future<List<BookBorrowModel>> getBookBorrowHistory(String bookId) async {
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.bookBorrowsCollectionId,
        queries: [
          Query.equal('book_id', bookId),
          Query.orderDesc('borrow_date'),
        ],
      );

      return docs.documents
          .map((doc) => BookBorrowModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching borrow history: $e');
      return [];
    }
  }

  void dispose() {
    _pollingTimer?.cancel();
    _booksController?.close();
  }
}
