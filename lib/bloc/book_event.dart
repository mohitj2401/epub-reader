part of 'book_bloc.dart';

@immutable
sealed class BookEvent {}

final class GetBooksEvent extends BookEvent {}

final class ScanBookEvent extends BookEvent {}

final class AddBookEvent extends BookEvent {}

final class SearchBooksEvent extends BookEvent {
  final String title;
  SearchBooksEvent({required this.title});
}

final class UpdateBookEvent extends BookEvent {
  final int id;
  final List<String>? highlightedText;
  final String? title;
  final String? status;
  final String? lastReadPage;
  final List<String>? authors;
  final bool? isExists;
  UpdateBookEvent({
    required this.id,
    this.highlightedText,
    this.title,
    this.status,
    this.lastReadPage,
    this.authors,
    this.isExists,
  });
}
