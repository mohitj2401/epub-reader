import 'package:book_read/datasource/book_datasource.dart';
import 'package:book_read/errors/failure.dart';
import 'package:book_read/exceptions/server_exception.dart';
import 'package:book_read/models/book_model.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class BookRepository {
  Future<Either<Failure, List<BookModel>>> fetchBooks();
  Future<Either<Failure, List<BookModel>>> searchBooks({required String title});
}

class BookRepositoryImp implements BookRepository {
  final BookDataSource bookDataSource;
  BookRepositoryImp(this.bookDataSource);

  @override
  Future<Either<Failure, List<BookModel>>> fetchBooks() async {
    try {
      final books = await bookDataSource.fetchBooks();
      return right(books);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<BookModel>>> searchBooks(
      {required String title}) async {
    try {
      final books = await bookDataSource.searchBooks(title: title);
      return right(books);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
