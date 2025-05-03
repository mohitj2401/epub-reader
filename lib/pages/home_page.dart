import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  TextEditingController title = TextEditingController();
  TextEditingController authors = TextEditingController();

  bottomSheetForeditBook(BookModel book) {
    title.text = book.title;
    authors.text = book.authors!.join(",");
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Update Book"),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: title,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Book Title"),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: authors,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Book Authors ( ',' seperated)"),
                ),
                ElevatedButton(
                    onPressed: () {
                      context.read<BookBloc>().add(UpdateBookEvent(
                          id: book.id!,
                          title: title.text,
                          authors: authors.text.split(",")));
                      book.authors = authors.text.split(",");
                      book.title = title.text;
                      Navigator.pop(context, book);
                    },
                    child: const Text("Submit"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> checkFileExists(String path) async {
    final file = File(path);

    return file.exists();
  }

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
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              customButton: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.find_in_page),
              ),
              items: [
                ...MenuItems.firstItems.map(
                  (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
              ],
              onChanged: (value) {
                switch (value) {
                  case MenuItems.home:
                    context.read<BookBloc>().add(ScanBookEvent());
                    //Do something
                    break;

                  case MenuItems.share:
                    context.read<BookBloc>().add(AddBookEvent());
                    //Do something

                    //Do something
                    break;
                }
              },
              dropdownStyleData: DropdownStyleData(
                width: 160,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  // color: Colors.redAccent,
                ),
                offset: const Offset(0, 8),
              ),
              menuItemStyleData: MenuItemStyleData(
                customHeights: [
                  ...List<double>.filled(MenuItems.firstItems.length, 48),
                ],
                padding: const EdgeInsets.only(left: 16, right: 16),
              ),
            ),
          ),
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
                    onPressed: () {
                      context.read<BookBloc>().add(AddBookEvent());
                    },
                    child: const Text("Select Epub"),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              itemCount: books.length,
              itemBuilder: (context, index) {
                
                return InkWell(
                  onTap: () async {
                    File file = File(books[index].filePath);
                    if (!(await file.exists())) {
                      context.read<BookBloc>().add(UpdateBookEvent(
                            id: books[index].id!,
                            isExists: false,
                          ));

                      showSnackBar(context,
                          "File does not exists in location (${books[index].filePath.replaceFirst("/storage/emulated/0/", "")})");
                      books[index].isExits = false;
                      setState(() {});
                      return;
                    }
                    final bytes = await file.readAsBytes();
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
                  child: Slidable(
                    key: ValueKey(index),
                    endActionPane: ActionPane(
                      dragDismissible: false,
                      // A motion is a widget used to control how the pane animates.
                      motion: const ScrollMotion(),

                      // A pane can dismiss the Slidable.
                      dismissible: DismissiblePane(onDismissed: () {}),

                      // All actions are defined in the children parameter.
                      children: [
                        // ElevatedButton(onPressed: () {}, child: Text("Edit")),
                        // ElevatedButton(onPressed: () {}, child: Text("Delete")),
                        // A SlidableAction can have an icon and/or a label.
                        // SlidableAction(
                        //   autoClose: true,
                        //   onPressed: (context) {
                        //     // bottomSheetForeditBook();
                        //   },
                        //   backgroundColor: Color(0xFFFE4A49),
                        //   foregroundColor: Colors.white,
                        //   icon: Icons.delete,
                        //   label: 'Delete',
                        // ),
                        SlidableAction(
                          autoClose: true,
                          onPressed: (context) async {
                            var res =
                                await bottomSheetForeditBook(books[index]);
                            if (res != null) {
                              books[index] = res;
                            }
                          },
                          backgroundColor: const Color(0xFF21B7CA),
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (books[index].isExits != null &&
                                    !books[index].isExits!)
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    child: Text(
                                      "File Does not Exists",
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(color: Colors.red[300]),
                                    ),
                                  )
                                : Container(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: books[index].image != null
                                      ? imgWdget.Image.memory(
                                          books[index].image!,
                                          height: 150,
                                          width: 150,
                                          // fit: BoxFit.fill,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          String status = "";
                                          if (books[index].status == "read") {
                                            status = "unread";
                                          } else {
                                            status = "read";
                                          }
                                          context.read<BookBloc>().add(
                                              UpdateBookEvent(
                                                  id: books[index].id!,
                                                  status: status));
                                          setState(() {
                                            books[index].status = status;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  books[index].status == "read"
                                                      ? Colors.green
                                                      : Colors.transparent,
                                            ),
                                            color: books[index].status == "read"
                                                ? Colors.green
                                                : Colors.transparent,
                                          ),
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: books[index].status == "read"
                                              ? const Text("Reading")
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
                          ],
                        ),
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

class MenuItem {
  const MenuItem({
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;
}

abstract class MenuItems {
  static const List<MenuItem> firstItems = [home, share];

  static const home = MenuItem(text: 'Scan', icon: Icons.search);
  static const share = MenuItem(text: 'Add Epub', icon: Icons.add);

  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, size: 22),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            item.text,
            style: const TextStyle(
                // color: Colors.white,
                ),
          ),
        ),
      ],
    );
  }

  static void onChanged(BuildContext context, MenuItem item) {}
}
