part of 'book_bloc.dart';

@immutable
sealed class BookState {}

final class BookInitial extends BookState {}

final class BookLoading extends BookState {}

final class BookDisplaySuccess extends BookState {
  final List<BookModel> books;
  BookDisplaySuccess(this.books);
}

final class SearchBookDisplaySuccess extends BookState {
  final List<BookModel> books;
  SearchBookDisplaySuccess(this.books);
}

final class BookFailure extends BookState {
  final String message;
  BookFailure(this.message);
}
