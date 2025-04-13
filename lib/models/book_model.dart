import 'dart:typed_data';

class BookModel {
  final String filePath;
  final String title;
  final Uint8List? image;
  final List<String?>? authors;
  final String status;
  final int lastReadPage;

  BookModel({
    required this.filePath,
    required this.title,
    this.image,
    this.authors,
    required this.status,
    required this.lastReadPage,
  });

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      filePath: map['filePath'],
      title: map['title'],
      image: map['image'] != null ? Uint8List.fromList(map['image']) : null,
      authors: map['authors'] != null
          ? (map['authors'] as String)
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : null,
      status: map['status'],
      lastReadPage: map['lastReadPage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'filePath': filePath,
      'title': title,
      'image': image,
      'authors': authors?.join(','),
      'status': status,
      'lastReadPage': lastReadPage,
    };
  }

  BookModel copyWith({
    String? filePath,
    String? title,
    Uint8List? image,
    List<String?>? authors,
    String? status,
    int? lastReadPage,
  }) {
    return BookModel(
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      image: image ?? this.image,
      authors: authors ?? this.authors,
      status: status ?? this.status,
      lastReadPage: lastReadPage ?? this.lastReadPage,
    );
  }
}
