import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:our_book_v2/bloc/book_bloc.dart';
import 'package:our_book_v2/models/book_model.dart';
import 'package:our_book_v2/pages/chapter_drawer.dart';
import 'package:our_book_v2/services/dictionary_service.dart';

class FlutterEpubViewerPage extends StatefulWidget {
  final BookModel bookModel;
  final bool showDrawer;
  const FlutterEpubViewerPage(
      {super.key, required this.bookModel, required this.showDrawer});

  @override
  State<FlutterEpubViewerPage> createState() => _FlutterEpubViewerPageState();
}

class _FlutterEpubViewerPageState extends State<FlutterEpubViewerPage> {
  List<String> hightedtexts = [];
  final epubController = EpubController();
  String currentPosition = "";
  String selectedText = "";
  var textSelectionCfi = '';

  bool isLoading = true;

  double progress = 0.0;

  addHighlightedText() {
    if (widget.bookModel.highlights != null) {
      widget.bookModel.highlights!.split("&@").forEach((text) {
        epubController.addHighlight(cfi: text);
      });
    }
    // setState(() {});
  }

  showDictionaryModel(BuildContext context, String word) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Start loading immediately
        Future.microtask(() async {
          final service = DictionaryService();
          final definition = await service.fetchDefinition(word);

          // Pop loading dialog
          Navigator.of(dialogContext).pop();

          // Show result dialog
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Definition of \"$word\""),
              content: Text(definition ?? "Definition not found."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Close"),
                ),
              ],
            ),
          );
        });

        // Show loading dialog
        return AlertDialog(
          title: Text("Please wait"),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(child: Text("Fetching definition...")),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    hightedtexts = widget.bookModel.highlights != null
        ? widget.bookModel.highlights!.split("&@")
        : [];
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: widget.showDrawer
          ? ChapterDrawer(
              controller: epubController,
            )
          : null,
      appBar: AppBar(
        title: Text(widget.bookModel.title),
      ),
      body: BlocListener<BookBloc, BookState>(
        listener: (context, state) {},
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, res) {
            context.read<BookBloc>().add(UpdateBookEvent(
                id: widget.bookModel.id!,
                highlightedText: hightedtexts,
                lastReadPage: currentPosition));
            BookModel bookModel = widget.bookModel;
            bookModel.highlights = hightedtexts.join("&@");
            bookModel.lastReadPage = currentPosition;

            if (!didPop) {
              print("object");
              Navigator.pop(context, bookModel);
            }
          },
          child: SafeArea(
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      EpubViewer(
                        initialCfi: widget.bookModel.lastReadPage,
                        epubSource: EpubSource.fromFile(
                            File(widget.bookModel.filePath)),
                        epubController: epubController,
                        displaySettings: EpubDisplaySettings(
                            flow: EpubFlow.paginated,
                            useSnapAnimationAndroid: false,
                            snap: true,
                            theme: EpubTheme.dark(),
                            allowScriptedContent: true),
                        selectionContextMenu: ContextMenu(
                          menuItems: [
                            ContextMenuItem(
                              title: "Highlight",
                              id: 1,
                              action: () async {
                                hightedtexts.add(textSelectionCfi);
                                epubController.addHighlight(
                                    cfi: textSelectionCfi);
                              },
                            ),
                            ContextMenuItem(
                              title: "Remove Highlight",
                              id: 2,
                              action: () async {
                                hightedtexts.remove(textSelectionCfi);
                                epubController.removeHighlight(
                                    cfi: textSelectionCfi);
                              },
                            ),
                            ContextMenuItem(
                              title: "Dictionary",
                              id: 3,
                              action: () async {
                                showDictionaryModel(context, selectedText);
                              },
                            ),
                          ],
                          settings: ContextMenuSettings(
                              hideDefaultSystemContextMenuItems: false),
                        ),
                        onChaptersLoaded: (chapters) {
                          setState(() {
                            isLoading = false;
                          });
                        },
                        onEpubLoaded: () async {
                          addHighlightedText();

                          print('Epub loaded');
                        },
                        onRelocated: (value) {
                          print("Reloacted to $value");
                          setState(() {
                            currentPosition = (value.startCfi);
                            progress = value.progress;
                          });
                        },
                        onAnnotationClicked: (cfi) {
                          print("Annotation clicked $cfi");
                        },
                        onTextSelected: (epubTextSelection) {
                          selectedText = epubTextSelection.selectedText;
                          textSelectionCfi = epubTextSelection.selectionCfi;
                          print(textSelectionCfi);
                        },
                      ),
                      Visibility(
                        visible: isLoading,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Text("${(progress * 100).toInt()}%"),
    );
  }
}
