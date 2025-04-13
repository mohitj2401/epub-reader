import 'package:book_read/bloc/book_bloc.dart';
import 'package:book_read/datasource/book_datasource.dart';
import 'package:book_read/repository/book_repo.dart';
import 'package:book_read/usecases/book_usecase.dart';
import 'package:book_read/usecases/search_usecase.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependancies() async {
  serviceLocator.registerFactory<BookDataSource>(() => BookDataSourceImp());

  serviceLocator.registerFactory<BookRepository>(
      () => BookRepositoryImp(serviceLocator()));

  serviceLocator.registerFactory(() => GetBooks(serviceLocator()));
  serviceLocator.registerFactory(() => SearchBooks(serviceLocator()));

  serviceLocator.registerLazySingleton(() =>
      BookBloc(getBooks: serviceLocator(), searchBooks: serviceLocator()));
}
