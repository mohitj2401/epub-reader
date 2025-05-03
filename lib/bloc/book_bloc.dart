import 'package:bloc/bloc.dart';
import 'package:our_book_v2/models/book_model.dart';
import 'package:our_book_v2/usecases/addfile_usecase.dart';
import 'package:our_book_v2/usecases/book_usecase.dart';
import 'package:our_book_v2/usecases/scanbooks_usecase.dart';
import 'package:our_book_v2/usecases/search_usecase.dart';
import 'package:our_book_v2/usecases/update_book_usecase.dart';
import 'package:our_book_v2/usecases/usecase.dart';
import 'package:meta/meta.dart';

part 'book_event.dart';
part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final GetBooks _getBooks;
  final SearchBooks _searchBooks;
  final ScanBooks _scanBooks;
  final UpdateBook _updateBook;
  final AddfileUsecase _addfileUsecase;

  BookBloc({
    required GetBooks getBooks,
    required SearchBooks searchBooks,
    required ScanBooks scanBooks,
    required UpdateBook updateBook,
      required AddfileUsecase addFileUsecase
  })  : _getBooks = getBooks,
        _searchBooks = searchBooks,
        _scanBooks = scanBooks,
        _updateBook = updateBook,
        _addfileUsecase = addFileUsecase,
        super(BookInitial()) {
    on<BookEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<GetBooksEvent>(_getAllBooks);
    on<SearchBooksEvent>(_searchAllBooks);
    on<ScanBookEvent>(_scanEpubFiles);
    on<UpdateBookEvent>(_updateBookFun);
    on<AddBookEvent>(_addfile);
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

  _updateBookFun(event, emit) async {
    emit(BookLoading());
    final res = await _updateBook(UpdateBookParam(
      id: event.id,
      status: event.status,
      highlightedText: event.highlightedText,
      title: event.title,
      lastReadPage: event.lastReadPage,
      authors: event.authors,
      exists: event.isExists,
    ));
    res.fold(
      (l) {
        emit(BookFailure(l.message));
      },
      (r) {
        emit(UpdateBookSuccess(r));
      },
    );
  }

  _addfile(event, emit) async {
    emit(AddFileLoading());
    final res = await _addfileUsecase(NoParams());
    res.fold(
      (l) {
        emit(BookFailure(l.message));
      },
      (r) {
        emit(AddFileSuccess());
      },
    );
  }
}
