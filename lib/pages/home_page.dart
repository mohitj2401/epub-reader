import 'package:our_book_v2/bloc/book_bloc.dart';
import 'package:our_book_v2/pages/search_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  Future<void> pickPdfFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      List<String> files = result.paths.whereType<String>().toList();
      print("Picked PDF files: $files");
    }
  }

  @override
  void initState() {
    context.read<BookBloc>().add(GetBooksEvent());
    pickPdfFiles();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Books"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, SearchPage.route());
            },
            icon: Icon(Icons.search),
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
            return RefreshIndicator(
              onRefresh: () async {
                context.read<BookBloc>().add(GetBooksEvent());
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                itemCount: state.books.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Image.network(
                              "https://covers.openlibrary.org/b/id/${state.books[index].coverId}-M.jpg",
                              // loadingBuilder:
                              //     (context, child, loadingProgress) => Icon(
                              //   Icons.image,
                              //   applyTextScaling: true,
                              // ),
                              // height: 500,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.books[index].title,
                                  style: TextStyle(fontSize: 18),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Authors : ${state.books[index].author.join(" , ")}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      state.books[index].status =
                                          !state.books[index].status;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: !state.books[index].status
                                            ? Colors.green
                                            : Colors.transparent,
                                      ),
                                      color: state.books[index].status
                                          ? Colors.green
                                          : Colors.transparent,
                                    ),
                                    duration: Duration(milliseconds: 200),
                                    child: state.books[index].status
                                        ? Text("Read")
                                        : Text("UnRead"),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Published: ${state.books[index].publishedYear}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
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
          return Center(
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
