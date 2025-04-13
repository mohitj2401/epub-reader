import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:epubx/epubx.dart';
import 'package:our_book_v2/datasource/book_datasource.dart';
import 'package:our_book_v2/exceptions/server_exception.dart';
import 'package:our_book_v2/models/book_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as imgS;


abstract interface class LocalDatasource {
  Future<List<BookModel>> fetchBooksFromStorage();
}

class LocalDatasourceImp implements LocalDatasource {
  LocalDatasourceImp(this.bookDataSource);
  BookDataSource bookDataSource;
  Future<List<File>> getPdfFilesSkippingProtectedFolders() async {
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      throw Exception("Storage permission not granted");
    }

    Directory root = Directory('/storage/emulated/0');
    List<File> pdfFiles = [];

    await for (FileSystemEntity entity
        in root.list(recursive: false, followLinks: false)) {
      try {
        // Skip Android folder
        if (entity is Directory && entity.path.contains("/Android")) continue;

        // Recursively check each subdirectory
        if (entity is Directory) {
          pdfFiles.addAll(await _scanDirectoryForPdfs(entity));
        }

        // Also check for PDF files directly under root
        if (entity is File && (entity.path.toLowerCase().endsWith('.epub'))) {
          pdfFiles.add(entity);
        }
      } catch (e) {
        // Just skip folders that throw access errors
        continue;
      }
    }
    return pdfFiles;
  }

  Future<List<File>> _scanDirectoryForPdfs(Directory dir) async {
    List<File> files = [];
    try {
      await for (FileSystemEntity entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity.path.contains('/Android')) continue;

        if (entity is File && entity.path.toLowerCase().endsWith('.epub')) {
          files.add(entity);
        }
      }
    } catch (_) {
      // Ignore access denied folders
    }
    return files;
  }

  @override
  Future<List<BookModel>> fetchBooksFromStorage() async {
    try {
      List<BookModel> books = [];
      List<File> scannedFiles = await getPdfFilesSkippingProtectedFolders();
      // print(scannedFiles.length);
      for (final file in scannedFiles) {
        try {
          List<int> bytes = await file.readAsBytes();
          EpubBook epubBook = await EpubReader.readBook(bytes);
          Uint8List? uint8list;
          if (epubBook.CoverImage != null) {
            // Create an image and encode it to PNG

            uint8list =
                Uint8List.fromList(imgS.encodeJpg(epubBook.CoverImage!));
          } else {
            Map<String, EpubByteContentFile>? images = epubBook.Content?.Images;
            if (images != null && images.isNotEmpty) {
              EpubByteContentFile firstImage = images.values.first;
              uint8list = Uint8List.fromList(firstImage.Content!);
            }
          }
          books.add(BookModel(
            filePath: file.path,
            status: "new",
            lastReadPage: 0,
            authors: epubBook.AuthorList,
            title: epubBook.Title ?? "Unknown",
            image: uint8list,
            type: "local",
          ));
        } catch (e) {
          print("Failed to read ${file.path}: $e");
        }
      }
      // scannedFiles.forEach((file) async {
      //   List<int> bytes = await file.readAsBytes();
      //   EpubBook epubBook = await EpubReader.readBook(bytes);
      //   books.add(BookModel(
      //     filePath: file.path,
      //     status: "new",
      //     lastReadPage: 0,
      //     authors: epubBook.AuthorList,
      //     title: epubBook.Title!,
      //   ));
      // });
      // print(books);

      bookDataSource.insertBooks(books);

      return books;
    } catch (e) {
      throw ServerException("Failed to fetch books: $e");
    }
  }
}
