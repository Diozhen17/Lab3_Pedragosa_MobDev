
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const LibraryApp());
}

// Abstract class
abstract class LibraryItem {
  String title;
  String author;
  bool borrowed;

  LibraryItem(this.title, this.author)
      : borrowed = false;

  void borrow();
  void returnBook();
}

// Mixin
mixin LibraryLogger {
  void log(String message) {
    debugPrint(message);
  }
}

// Inheritance
class Book extends LibraryItem with LibraryLogger {
  Book(super.title, super.author);

  @override
  void borrow() {
    if (borrowed) {
      throw Exception('$title is already borrowed.');
    }
    borrowed = true;
    log('$title borrowed successfully.');
  }

  @override
  void returnBook() {
    if (!borrowed) {
      throw Exception('$title is not borrowed.');
    }
    borrowed = false;
    log('$title returned successfully.');
  }
}

class Library {
  final String name;
  final List<Book> books;

  Library(this.name, this.books);

  Future<void> loadData() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );
  }
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Library System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const LibraryPage(),
    );
  }
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late final Library library;

  bool loading = true;
  final List<String> logs = [];

  @override
  void initState() {
    super.initState();

    library = Library('Community Library', [
      Book('Noli Me Tangere', 'Jose Rizal'),
      Book('El Filibusterismo', 'Jose Rizal'),
      Book('Florante at Laura', 'Francisco Balagtas'),
    ]);

    loadLibrary();
  }

  Future<void> loadLibrary() async {
    setState(() => loading = true);
    addLog('Loading library data...');

    try {
      await library.loadData();

      if (!mounted) return;

      setState(() => loading = false);
      addLog('Library data loaded successfully!');
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      addLog('Error: $e');
    }
  }

  void addLog(String message) {
    setState(() => logs.insert(0, message));
  }

  void performAction(Book book, bool borrow) {
    try {
      if (borrow) {
        book.borrow();
      } else {
        book.returnBook();
      }

      setState(() {});
      addLog(
        '${book.title}: ${borrow ? "Borrowed" : "Returned"} successfully.',
      );
    } catch (e) {
      addLog('Error handled: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF172747),
        foregroundColor: Colors.white,
        title: const Text('📚 Library Management System'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFE4EDFF),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to the Library!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Borrow, read, and return your favorite books.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: loading
                  ? const CircularProgressIndicator()
                  : const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
              title: Text(
                loading
                    ? 'Loading library data...'
                    : 'Library data loaded!',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: loadLibrary,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Book Catalog',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ...library.books.map(
            (book) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Author: ${book.author}'),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        book.borrowed
                            ? 'Borrowed'
                            : 'Available',
                      ),
                      avatar: Icon(
                        book.borrowed
                            ? Icons.book
                            : Icons.check_circle,
                        size: 18,
                      ),
                      backgroundColor: book.borrowed
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton(
                          onPressed: loading || book.borrowed
                              ? null
                              : () => performAction(book, true),
                          child: const Text('Borrow'),
                        ),
                        OutlinedButton(
                          onPressed: loading || !book.borrowed
                              ? null
                              : () => performAction(book, false),
                          child: const Text('Return'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          Card(
            color: const Color(0xFF172747),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activity Logs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  if (logs.isEmpty)
                    const Text(
                      'No activity yet.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ...logs.map(
                    (message) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      child: Text(
                        '> $message',
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() => logs.clear());
                      },
                      child: const Text(
                        'Clear Logs',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
