import 'package:our_book_v2/errors/failure.dart';
import 'package:our_book_v2/models/book_model.dart';
import 'package:our_book_v2/repository/book_repo.dart';
import 'package:our_book_v2/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';

class GetBooks implements UseCase {
  final BookRepository bookRepository;
  GetBooks(this.bookRepository);

  @override
  Future<Either<Failure, List<BookModel>>> call(params) {
    return bookRepository.fetchBooks();
  }
}
