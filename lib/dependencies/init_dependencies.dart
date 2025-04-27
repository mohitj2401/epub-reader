import 'package:our_book_v2/bloc/book_bloc.dart';
import 'package:our_book_v2/datasource/book_datasource.dart';
import 'package:our_book_v2/datasource/local_datasource.dart';
import 'package:our_book_v2/repository/book_repo.dart';
import 'package:our_book_v2/usecases/addfile_usecase.dart';
import 'package:our_book_v2/usecases/book_usecase.dart';
import 'package:our_book_v2/usecases/scanbooks_usecase.dart';
import 'package:our_book_v2/usecases/search_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:our_book_v2/usecases/update_book_usecase.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependancies() async {
  serviceLocator.registerFactory<BookDataSource>(() => BookDataSourceImp());

  serviceLocator.registerFactory<BookRepository>(
      () => BookRepositoryImp(serviceLocator(), serviceLocator()));

  serviceLocator.registerFactory(() => GetBooks(serviceLocator()));
  serviceLocator.registerFactory(() => SearchBooks(serviceLocator()));
  serviceLocator.registerFactory(() => ScanBooks(serviceLocator()));
  serviceLocator.registerFactory(() => UpdateBook(serviceLocator()));
  serviceLocator.registerFactory(() => AddfileUsecase(serviceLocator()));

  serviceLocator.registerLazySingleton(() =>
      BookBloc(
        getBooks: serviceLocator(),
        searchBooks: serviceLocator(),
        scanBooks: serviceLocator(),
        updateBook: serviceLocator(),
        addFileUsecase: serviceLocator(),
      ));

  serviceLocator.registerFactory<LocalDatasource>(
      () => LocalDatasourceImp(serviceLocator()));
  
}
