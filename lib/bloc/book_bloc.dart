import 'package:bloc/bloc.dart';
import 'package:book_read/models/book_model.dart';
import 'package:book_read/usecases/book_usecase.dart';
import 'package:book_read/usecases/search_usecase.dart';
import 'package:book_read/usecases/usecase.dart';
import 'package:meta/meta.dart';

part 'book_event.dart';
part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final GetBooks _getBooks;
  final SearchBooks _searchBooks;

  BookBloc({required GetBooks getBooks, required SearchBooks searchBooks})
      : _getBooks = getBooks,
        _searchBooks = searchBooks,
        super(BookInitial()) {
    on<BookEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<GetBooksEvent>(_getAllBooks);
    on<SearchBooksEvent>(_searchAllBooks);
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
}
