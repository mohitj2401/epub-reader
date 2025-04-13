import 'dart:async';
import 'package:our_book_v2/exceptions/server_exception.dart';
import 'package:our_book_v2/models/book_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract interface class BookDataSource {
  Future<List<BookModel>> fetchBooks();
  Future<List<BookModel>> searchBooks({required String title});
  Future<void> insertBooks(List<BookModel> books);
}

class BookDataSourceImp implements BookDataSource {
  Database? _database;

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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE books (
        filePath TEXT PRIMARY KEY,
        title TEXT,
        image BLOB,
        authors TEXT,
        status TEXT,
        lastReadPage INTEGER,
        type TEXT,
      )
        ''');
      },
    );
  }

  @override
  Future<List<BookModel>> fetchBooks() async {
    try {
      final db = await database;
      final result = await db.query('books');
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
}
