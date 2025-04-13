import 'package:book_read/errors/failure.dart';
import 'package:book_read/models/book_model.dart';
import 'package:book_read/repository/book_repo.dart';
import 'package:book_read/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';

class SearchBooks implements UseCase<List<BookModel>, SearchBooksParams> {
  final BookRepository bookRepository;
  SearchBooks(this.bookRepository);

  @override
  Future<Either<Failure, List<BookModel>>> call(params) {
    return bookRepository.searchBooks(title: params.title);
  }
}

class SearchBooksParams {
  final String title;
  SearchBooksParams({required this.title});
}
