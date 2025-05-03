import 'dart:async';
import 'package:logger/logger.dart';
import 'package:our_book_v2/exceptions/server_exception.dart';
import 'package:our_book_v2/models/book_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract interface class BookDataSource {
  Future<List<BookModel>> fetchBooks();
  Future<List<BookModel>> searchBooks({required String title});
  Future<void> insertBooks(List<BookModel> books);
  Future<void> updateLastReadPage(int id, String page);
  Future<void> updateHighlights(int id, String highlightsJson);
  Future<bool> updateBookDetails(
      {required int id,
      String? newTitle,
      List<String>? newAuthors,
      List<String>? highlights,
      String? status,
      String? lastReadPage,
      bool? exists});
}

class BookDataSourceImp implements BookDataSource {
  Database? _database;
  Logger logger = Logger();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'books.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY,
        filePath UNIQUE,
        title TEXT,
        image BLOB,
        authors TEXT,
        status TEXT,
        lastReadPage TEXT,
        type TEXT,
        highlights TEXT
      )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Example: add a new column 'rating'
          await db.execute('ALTER TABLE books ADD COLUMN isExists TINYINT');
        }
      },
    );
  }

  @override
  Future<List<BookModel>> fetchBooks() async {
    try {
      final db = await database;
      final result = await db.query('books');
      // logger.d(result.length);
      return result.map((e) => BookModel.fromMap(e)).toList();
    } catch (e) {
      throw ServerException("Failed to fetch books: $e");
    }
  }

  @override
  Future<List<BookModel>> searchBooks({required String title}) async {
    try {
      final db = await database;
      final result = await db.query(
        'books',
        where: 'title LIKE ?',
        whereArgs: ['%$title%'],
      );
      return result.map((e) => BookModel.fromMap(e)).toList();
    } catch (e) {
      throw ServerException("Failed to search books: $e");
    }
  }

  @override
  Future<void> insertBooks(List<BookModel> books) async {
    try {
      final db = await database;
      final batch = db.batch();
      for (final book in books) {
        batch.insert(
          'books',
          book.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      throw ServerException("Failed to insert books: $e");
    }
  }

  @override
  Future<void> updateLastReadPage(int id, String page) async {
    try {
      final db = await database;
      await db.update(
        'books',
        {'lastReadPage': page},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw ServerException("Failed to update last read page: $e");
    }
  }

  // Update highlights (expects a JSON string)
  @override
  Future<void> updateHighlights(int id, String highlightsJson) async {
    try {
      final db = await database;
      await db.update(
        'books',
        {'highlights': highlightsJson},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw ServerException("Failed to update highlights: $e");
    }
  }

  @override
  Future<bool> updateBookDetails(
      {required int id,
      String? newTitle,
      List<String>? newAuthors,
      List<String>? highlights,
      String? status,
      String? lastReadPage,
      bool? exists}) async {
    try {
      final db = await database;
      // print(exists);
      // Prepare the update map
      final Map<String, Object?> updateFields = {};
      if (lastReadPage != null) updateFields['lastReadPage'] = lastReadPage;
      if (newTitle != null) updateFields['title'] = newTitle;
      if (status != null) updateFields['status'] = status;
      if (highlights != null) {
        updateFields['highlights'] = highlights.join('&@');
      }
      if (exists != null) {
        updateFields['isExists'] = exists ? 1 : 0;
      }
      if (newAuthors != null) updateFields['authors'] = newAuthors.join(',');

      if (updateFields.isEmpty) return false; // Nothing to update
      await db.update(
        'books',
        updateFields,
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      throw ServerException("Failed to update book details: $e");
    }
  }
}
