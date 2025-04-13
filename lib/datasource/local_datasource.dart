import 'package:our_book_v2/exceptions/server_exception.dart';
import 'package:our_book_v2/models/book_model.dart';
import 'package:dio/dio.dart';

abstract interface class LocalDataSource {
  Future<List<BookModel>> fetchBooks();

  Future<List<BookModel>> searchBooks({required String title});
}

class LocalDataSourceImp implements LocalDataSource {
  LocalDataSourceImp();

  @override
  Future<List<BookModel>> fetchBooks() async {
    try {
      Dio dio = Dio();
      final response = await dio.get(
          "https://openlibrary.org/people/mekBot/books/already-read.json?limit=20");
      List<BookModel> books = [];
      if (response.statusCode == 200) {
        response.data["reading_log_entries"].forEach((work) {
          books.add(BookModel.fromMap(work["work"]));
        });
        return books;
      } else {
        throw ServerException("Book Library Server Error");
      }
    } on DioException catch (e) {
      throw ServerException(e.message!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BookModel>> searchBooks({required String title}) async {
    try {
      Dio dio = Dio();

      final response = await dio.get(
          "https://openlibrary.org/search.json?title=${title.replaceAll(" ", "+")}&fields=title,author_name,first_publish_year,cover_i");
      List<BookModel> books = [];
      if (response.statusCode == 200) {
        response.data["docs"].forEach((work) {
          books.add(BookModel.fromMap(work).copyWith(coverId: work["cover_i"]));
        });
        return books;
      } else {
        throw ServerException("Book Library Server Error");
      }
    } on DioException catch (e) {
      throw ServerException(e.message!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
