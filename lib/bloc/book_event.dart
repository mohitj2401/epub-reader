part of 'book_bloc.dart';

@immutable
sealed class BookEvent {}

final class GetBooksEvent extends BookEvent {}

final class SearchBooksEvent extends BookEvent {
  final String title;
  SearchBooksEvent({required this.title});
}
