import 'package:bloc/bloc.dart';
import 'package:our_book_v2/models/book_model.dart';
import 'package:our_book_v2/usecases/book_usecase.dart';
import 'package:our_book_v2/usecases/scanbooks_usecase.dart';
import 'package:our_book_v2/usecases/search_usecase.dart';
import 'package:our_book_v2/usecases/usecase.dart';
import 'package:meta/meta.dart';

part 'book_event.dart';
part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final GetBooks _getBooks;
  final SearchBooks _searchBooks;
  final ScanBooks _scanBooks;

  BookBloc({
    required GetBooks getBooks,
    required SearchBooks searchBooks,
    required ScanBooks scanBooks,
  })  : _getBooks = getBooks,
        _searchBooks = searchBooks,
        _scanBooks = scanBooks,
        super(BookInitial()) {
    on<BookEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<GetBooksEvent>(_getAllBooks);
    on<SearchBooksEvent>(_searchAllBooks);
    on<ScanBookEvent>(_scanEpubFiles);
  }
  _getAllBooks(event, emit) async {
    emit(BookLoading());
    final res = await _getBooks(NoParams());
    res.fold(
      (l) {
        emit(BookFailure(l.message));
      },
      (r) {
        emit(BookDisplaySuccess(r));
      },
    );
  }

  _searchAllBooks(event, emit) async {
    emit(BookLoading());
    final res = await _searchBooks(SearchBooksParams(title: event.title));
    res.fold(
      (l) {
        emit(BookFailure(l.message));
      },
      (r) {
        emit(SearchBookDisplaySuccess(r));
      },
    );
  }

  _scanEpubFiles(event, emit) async {
    emit(BookLoading());
    final res = await _scanBooks(NoParams());
    res.fold(
      (l) {
        emit(BookFailure(l.message));
      },
      (r) {
        emit(BookDisplaySuccess(r));
      },
    );
  }
}
