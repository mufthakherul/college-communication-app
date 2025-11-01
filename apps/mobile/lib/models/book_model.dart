enum BookCategory {
  textbook,
  reference,
  fiction,
  technical,
  research,
  magazine,
  journal,
  other
}

enum BookStatus { available, borrowed, reserved, maintenance }

class BookModel {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final BookCategory category;
  final String description;
  final String? coverUrl;
  final String? fileUrl; // For digital books (PDF)
  final BookStatus status;
  final String publisher;
  final String edition;
  final int publicationYear;
  final int totalCopies;
  final int availableCopies;
  final String department; // Which department this book belongs to
  final String? tags; // Comma-separated tags for better search
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String addedBy; // User ID who added the book

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.isbn = '',
    required this.category,
    this.description = '',
    this.coverUrl,
    this.fileUrl,
    this.status = BookStatus.available,
    this.publisher = '',
    this.edition = '',
    this.publicationYear = 0,
    this.totalCopies = 1,
    this.availableCopies = 1,
    this.department = '',
    this.tags,
    required this.createdAt,
    this.updatedAt,
    required this.addedBy,
  });

  factory BookModel.fromJson(Map<String, dynamic> data) {
    return BookModel(
      id: data['id'] ?? data['\$id'] ?? '',
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      isbn: data['isbn'] ?? '',
      category: _parseCategory(data['category']),
      description: data['description'] ?? '',
      coverUrl: data['cover_url'],
      fileUrl: data['file_url'],
      status: _parseStatus(data['status']),
      publisher: data['publisher'] ?? '',
      edition: data['edition'] ?? '',
      publicationYear: data['publication_year'] ?? 0,
      totalCopies: data['total_copies'] ?? 1,
      availableCopies: data['available_copies'] ?? 1,
      department: data['department'] ?? '',
      tags: data['tags'],
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : null,
      addedBy: data['added_by'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'category': category.name,
      'description': description,
      'cover_url': coverUrl,
      'file_url': fileUrl,
      'status': status.name,
      'publisher': publisher,
      'edition': edition,
      'publication_year': publicationYear,
      'total_copies': totalCopies,
      'available_copies': availableCopies,
      'department': department,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'added_by': addedBy,
    };
  }

  static BookCategory _parseCategory(String? categoryStr) {
    switch (categoryStr?.toLowerCase()) {
      case 'textbook':
        return BookCategory.textbook;
      case 'reference':
        return BookCategory.reference;
      case 'fiction':
        return BookCategory.fiction;
      case 'technical':
        return BookCategory.technical;
      case 'research':
        return BookCategory.research;
      case 'magazine':
        return BookCategory.magazine;
      case 'journal':
        return BookCategory.journal;
      default:
        return BookCategory.other;
    }
  }

  static BookStatus _parseStatus(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'available':
        return BookStatus.available;
      case 'borrowed':
        return BookStatus.borrowed;
      case 'reserved':
        return BookStatus.reserved;
      case 'maintenance':
        return BookStatus.maintenance;
      default:
        return BookStatus.available;
    }
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    BookCategory? category,
    String? description,
    String? coverUrl,
    String? fileUrl,
    BookStatus? status,
    String? publisher,
    String? edition,
    int? publicationYear,
    int? totalCopies,
    int? availableCopies,
    String? department,
    String? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? addedBy,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      category: category ?? this.category,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      status: status ?? this.status,
      publisher: publisher ?? this.publisher,
      edition: edition ?? this.edition,
      publicationYear: publicationYear ?? this.publicationYear,
      totalCopies: totalCopies ?? this.totalCopies,
      availableCopies: availableCopies ?? this.availableCopies,
      department: department ?? this.department,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      addedBy: addedBy ?? this.addedBy,
    );
  }

  bool get isAvailable => availableCopies > 0 && status == BookStatus.available;

  String get categoryDisplayName {
    switch (category) {
      case BookCategory.textbook:
        return 'Textbook';
      case BookCategory.reference:
        return 'Reference';
      case BookCategory.fiction:
        return 'Fiction';
      case BookCategory.technical:
        return 'Technical';
      case BookCategory.research:
        return 'Research';
      case BookCategory.magazine:
        return 'Magazine';
      case BookCategory.journal:
        return 'Journal';
      case BookCategory.other:
        return 'Other';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case BookStatus.available:
        return 'Available';
      case BookStatus.borrowed:
        return 'Borrowed';
      case BookStatus.reserved:
        return 'Reserved';
      case BookStatus.maintenance:
        return 'Maintenance';
    }
  }
}

// Book Borrowing Record Model
class BookBorrowModel {
  final String id;
  final String bookId;
  final String userId;
  final String userName;
  final String userEmail;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final String status; // 'borrowed', 'returned', 'overdue'
  final String? notes;

  BookBorrowModel({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    required this.status,
    this.notes,
  });

  factory BookBorrowModel.fromJson(Map<String, dynamic> data) {
    return BookBorrowModel(
      id: data['id'] ?? data['\$id'] ?? '',
      bookId: data['book_id'] ?? '',
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? '',
      userEmail: data['user_email'] ?? '',
      borrowDate: DateTime.parse(data['borrow_date']),
      dueDate: DateTime.parse(data['due_date']),
      returnDate: data['return_date'] != null
          ? DateTime.parse(data['return_date'])
          : null,
      status: data['status'] ?? 'borrowed',
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'borrow_date': borrowDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  bool get isOverdue {
    if (returnDate != null) return false;
    return DateTime.now().isAfter(dueDate);
  }

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }
}
