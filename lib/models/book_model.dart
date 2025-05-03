import 'dart:typed_data';

class BookModel {
  int? id;
  String filePath;
  String title;
  Uint8List? image;
  List<String?>? authors;
  String status;
  String? lastReadPage;
  String? highlights;
  String? type;
  bool? isExits;

  BookModel({
    required this.filePath,
    required this.title,
    this.image,
    this.authors,
    required this.status,
    this.lastReadPage,
    required this.type,
    this.id,
    this.highlights,
    this.isExits,
  });

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'],
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
      highlights: map['highlights'],
      status: map['status'],
      lastReadPage: map['lastReadPage'],
      type: map["type"],
      isExits: map["isExists"] == 0 ? false : true,
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
      "type": type,
      "id": id,
      "highlights": highlights,
      'exists': isExits
    };
  }

  BookModel copyWith({
    String? filePath,
    String? title,
    String? type,
    Uint8List? image,
    List<String?>? authors,
    String? status,
    String? lastReadPage,
    int? id,
    String? highlights,
    bool? isExists,
  }) {
    return BookModel(
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      image: image ?? this.image,
      type: type ?? this.type,
      authors: authors ?? this.authors,
      status: status ?? this.status,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      id: id ?? this.id,
      highlights: highlights ?? this.highlights,
      isExits: isExits ?? isExits,
    );
  }
}
