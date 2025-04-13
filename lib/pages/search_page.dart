import 'package:book_read/bloc/book_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const SearchPage());
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController search = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    search.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Books"),
      ),
      body: PopScope(
        onPopInvoked: (val) {
          context.read<BookBloc>().add(GetBooksEvent());
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                scrollPadding: EdgeInsets.zero,
                controller: search,
                decoration: InputDecoration(
                  // isDense: true,
                  prefixIcon: Icon(Icons.abc),
                  suffix: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (search.text.isEmpty) {
                          showSnackBar(context, "Please enter book title");
                        } else {
                          context
                              .read<BookBloc>()
                              .add(SearchBooksEvent(title: search.text.trim()));
                        }
                      },
                      icon: Icon(Icons.search)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            BlocConsumer<BookBloc, BookState>(
              listener: (context, state) {
                if (state is BookFailure) {
                  showSnackBar(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is SearchBookDisplaySuccess) {
                  return Expanded(
                    child: Scrollbar(
                      child: ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
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
                                                color:
                                                    !state.books[index].status
                                                        ? Colors.green
                                                        : Colors.transparent,
                                              ),
                                              color: state.books[index].status
                                                  ? Colors.green
                                                  : Colors.transparent,
                                            ),
                                            duration:
                                                Duration(milliseconds: 200),
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
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
                    ),
                  );
                }
                if (state is BookLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Center(
                  child: Text("Search Book by title"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
