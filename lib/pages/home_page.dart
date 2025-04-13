import 'dart:io';
import 'dart:typed_data';

import 'package:epubx/epubx.dart';
import 'package:our_book_v2/bloc/book_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/src/widgets/image.dart' as imgWdget;
import 'package:image/image.dart' as imgS;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<File> bookList = [];
  List<List<String>> bookPropertyList = [];
  List<File> scannedFiles = [];
  List<EpubBook> books = [];

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

              // Navigator.push(context, SearchPage.route());
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
        },
        builder: (context, state) {
          if (state is BookDisplaySuccess) {
            if (state.books.isEmpty) {
              return Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("No Epud Exist please choose an option"),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BookBloc>().add(ScanBookEvent());
                      },
                      child: Text("Scan For Epub"),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("Select Epub"),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<BookBloc>().add(GetBooksEvent());
              },
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                itemCount: state.books.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: state.books[index].image != null
                                ? imgWdget.Image.memory(
                                    state.books[index].image!,
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
                                  state.books[index].title,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Authors : ${state.books[index].authors?.join(" , ")}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                // InkWell(
                                //   onTap: () {
                                //     setState(() {
                                //       state.books[index].status =
                                //           !state.books[index].status;
                                //     });
                                //   },
                                //   child: AnimatedContainer(
                                //     padding: EdgeInsets.symmetric(
                                //         vertical: 5, horizontal: 10),
                                //     decoration: BoxDecoration(
                                //       border: Border.all(
                                //         color: !state.books[index].status
                                //             ? Colors.green
                                //             : Colors.transparent,
                                //       ),
                                //       color: state.books[index].status
                                //           ? Colors.green
                                //           : Colors.transparent,
                                //     ),
                                //     duration: Duration(milliseconds: 200),
                                //     child: state.books[index].status
                                //         ? Text("Read")
                                //         : Text("UnRead"),
                                //   ),
                                // ),
                                // SizedBox(
                                //   height: 20,
                                // ),
                                // Text(
                                //   "Published: ${state.books[index].publishedYear}",
                                //   style: TextStyle(
                                //     fontSize: 14,
                                //     color:
                                //         Theme.of(context).colorScheme.tertiary,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
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
