import 'dart:io';

import 'package:epubx/epubx.dart';
import 'package:our_book_v2/bloc/book_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/src/widgets/image.dart' as imgWdget;
import 'package:our_book_v2/models/book_model.dart';
import 'package:our_book_v2/pages/flutter_epub_viewer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<File> bookList = [];
  List<List<String>> bookPropertyList = [];
  List<File> scannedFiles = [];
  List<BookModel> books = [];

  @override
  void initState() {
    context.read<BookBloc>().add(GetBooksEvent());
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Books"),
        actions: [
          IconButton(
            onPressed: () {
              context.read<BookBloc>().add(ScanBookEvent());
            },
            icon: const Icon(Icons.find_in_page),
          )
        ],
      ),
      body: BlocConsumer<BookBloc, BookState>(
        listener: (context, state) {
          if (state is BookFailure) {
            showSnackBar(context, state.message);
          }
          if (state is BookDisplaySuccess) {
            books = state.books;
          }
        },
        builder: (context, state) {
          if (books.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("No Epud Exist please choose an option"),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BookBloc>().add(ScanBookEvent());
                    },
                    child: const Text("Scan For Epub"),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Select Epub"),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              // context.read<BookBloc>().add(GetBooksEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              itemCount: books.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () async {
                    final bytes =
                        await File(books[index].filePath).readAsBytes();
                    final book = await EpubReader.readBook(bytes);
                    var res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => FlutterEpubViewerPage(
                                  bookModel: books[index],
                                  showDrawer: (book.Chapters?.length != null &&
                                          book.Chapters!.length < 2)
                                      ? false
                                      : true,
                                )));
                    if (res != null) {
                      books[index] = res;
                    }
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: books[index].image != null
                                ? imgWdget.Image.memory(
                                    books[index].image!,
                                  )
                                : const Icon(
                                    Icons.broken_image_outlined,
                                    size: 100,
                                  ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  books[index].title,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Authors : ${books[index].authors?.join(" , ")}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: AnimatedContainer(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: books[index].status == "read"
                                            ? Colors.green
                                            : Colors.transparent,
                                      ),
                                      color: books[index].status == "read"
                                          ? Colors.green
                                          : Colors.transparent,
                                    ),
                                    duration: const Duration(milliseconds: 200),
                                    child: books[index].status == "read"
                                        ? const Text("Read")
                                        : const Text("UnRead"),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                // Text(
                                //   "Published: ${books[index].publishedYear}",
                                //   style: TextStyle(
                                //     fontSize: 14,
                                //     color: Theme.of(context)
                                //         .colorScheme
                                //         .tertiary,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
