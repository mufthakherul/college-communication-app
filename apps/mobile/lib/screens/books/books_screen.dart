import 'package:campus_mesh/models/book_model.dart';
import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/screens/books/book_detail_screen.dart';
import 'package:campus_mesh/screens/books/create_book_screen.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/books_service.dart';
import 'package:flutter/material.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _booksService = BooksService();
  final _authService = AuthService();
  UserModel? _currentUser;
  BookCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isSearching = false;
  List<BookModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
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

  bool get _canAddBooks {
    return _currentUser?.role == UserRole.admin ||
        _currentUser?.role == UserRole.teacher;
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    final results = await _booksService.searchBooks(query);
    if (mounted) {
      setState(() => _searchResults = results);
    }
  }

  Widget _buildCategoryChip(BookCategory category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(_getCategoryName(category)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
    );
  }

  String _getCategoryName(BookCategory category) {
    switch (category) {
      case BookCategory.textbook:
        return 'Textbooks';
      case BookCategory.reference:
        return 'Reference';
      case BookCategory.fiction:
        return 'Fiction';
      case BookCategory.technical:
        return 'Technical';
      case BookCategory.research:
        return 'Research';
      case BookCategory.magazine:
        return 'Magazines';
      case BookCategory.journal:
        return 'Journals';
      case BookCategory.other:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search books...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _performSearch(value);
                },
              )
            : const Text('Library'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchResults = [];
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filters
          if (!_isSearching)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  FilterChip(
                    label: const Text('All Books'),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ...BookCategory.values.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildCategoryChip(cat),
                    ),
                  ),
                ],
              ),
            ),
          // Books list
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : _selectedCategory == null
                    ? _buildAllBooks()
                    : _buildCategoryBooks(_selectedCategory!),
          ),
        ],
      ),
      floatingActionButton: _canAddBooks
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateBookScreen(),
                  ),
                );
                if (result == true) {
                  // Book added, list will auto-refresh
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Book'),
            )
          : null,
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Search for books by title or author',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No books found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildBookCard(_searchResults[index]);
      },
    );
  }

  Widget _buildAllBooks() {
    return StreamBuilder<List<BookModel>>(
      stream: _booksService.getBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: SelectableText('Error: ${snapshot.error}'));
        }

        final books = snapshot.data ?? [];

        if (books.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_books, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No books in library yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return _buildBookCard(books[index]);
          },
        );
      },
    );
  }

  Widget _buildCategoryBooks(BookCategory category) {
    return FutureBuilder<List<BookModel>>(
      future: _booksService.getBooksByCategory(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: SelectableText('Error: ${snapshot.error}'));
        }

        final books = snapshot.data ?? [];

        if (books.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.library_books, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No ${_getCategoryName(category).toLowerCase()} found',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return _buildBookCard(books[index]);
          },
        );
      },
    );
  }

  Widget _buildBookCard(BookModel book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailScreen(book: book),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                  image: book.coverUrl != null
                      ? DecorationImage(
                          image: NetworkImage(book.coverUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: book.coverUrl == null
                    ? const Icon(Icons.book, size: 32, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              // Book details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(book.category),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            book.categoryDisplayName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          book.isAvailable ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: book.isAvailable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          book.isAvailable ? 'Available' : 'Not Available',
                          style: TextStyle(
                            fontSize: 12,
                            color: book.isAvailable ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    if (book.isAvailable)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${book.availableCopies}/${book.totalCopies} copies available',
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
        ),
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

  @override
  void dispose() {
    _booksService.dispose();
    super.dispose();
  }
}
