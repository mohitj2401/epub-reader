import 'package:our_book_v2/datasource/book_datasource.dart';
import 'package:our_book_v2/datasource/local_datasource.dart';
import 'package:our_book_v2/errors/failure.dart';
import 'package:our_book_v2/exceptions/server_exception.dart';
import 'package:our_book_v2/models/book_model.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class BookRepository {
  Future<Either<Failure, List<BookModel>>> fetchBooks();
  Future<Either<Failure, List<BookModel>>> scanBooks();
  Future<Either<Failure, void>> pickFile();
  Future<Either<Failure, List<BookModel>>> searchBooks({required String title});
  Future<Either<Failure, bool>> updateBook(
      {required int id,
      String? newTitle,
      List<String>? newAuthors,
      List<String>? highlights,
      String? status,
      String? lastReadPage,
      bool? exists});
}

class BookRepositoryImp implements BookRepository {
  final BookDataSource bookDataSource;
  final LocalDatasource localDatasource;
  BookRepositoryImp(this.bookDataSource, this.localDatasource);

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

  @override
  Future<Either<Failure, List<BookModel>>> scanBooks() async {
    try {
      final books = await localDatasource.fetchBooksFromStorage();
      return right(books);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
  
  @override
  Future<Either<Failure, bool>> updateBook(
      {required int id,
      String? newTitle,
      List<String>? newAuthors,
      List<String>? highlights,
      String? status,
      String? lastReadPage,
      bool? exists}) async {
    try {
      final res = await bookDataSource.updateBookDetails(
          id: id,
          newTitle: newTitle,
          newAuthors: newAuthors,
          status: status,
          lastReadPage: lastReadPage,
          highlights: highlights,
          exists: exists);
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
  
  @override
  Future<Either<Failure, void>> pickFile() async {
    try {
      final books = await localDatasource.pickAndInsertFile();
      return right(books);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
