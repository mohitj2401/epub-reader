// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fpdart/fpdart.dart';

import 'package:our_book_v2/errors/failure.dart';
import 'package:our_book_v2/repository/book_repo.dart';
import 'package:our_book_v2/usecases/usecase.dart';

class UpdateBook implements UseCase<bool, UpdateBookParam> {
  final BookRepository bookRepository;
  UpdateBook(this.bookRepository);

  @override
  Future<Either<Failure,bool>> call(params) {
    return bookRepository.updateBook(
      id: params.id,
      status: params.status,
      highlights: params.highlightedText,
      newTitle: params.title,
      lastReadPage: params.lastReadPage,
      newAuthors: params.authors,
    );
  }
}

class UpdateBookParam {
  final int id;
  final List<String>? highlightedText;
  final String? title;
  final String? status;
  final String? lastReadPage;
  final List<String>? authors;
  UpdateBookParam({
    required this.id,
    this.highlightedText,
    this.title,
    this.status,
    this.lastReadPage,
    this.authors,
  });
}
