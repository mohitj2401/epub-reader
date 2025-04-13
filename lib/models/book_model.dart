class BookModel {
  final String title;
  final List<String> author;
  final int? publishedYear;
  bool status;
  final int? coverId;
  BookModel({
    required this.title,
    required this.author,
    required this.publishedYear,
    this.status = false,
    this.coverId,
  });

  BookModel copyWith({
    String? title,
    List<String>? author,
    int? publishedYear,
    bool? status,
    int? coverId,
  }) {
    return BookModel(
      title: title ?? this.title,
      author: author ?? this.author,
      publishedYear: publishedYear ?? this.publishedYear,
      status: status ?? this.status,
      coverId: coverId ?? this.coverId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'author': author,
      'first_publish_year': publishedYear,
      'status': status,
      'coverId': coverId,
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      title: map['title'] as String,
      author: map['author_names'] == null && map["author_name"] == null
          ? []
          : map['author_names'] == null
              ? List<String>.from(
                  (map['author_name']),
                )
              : List<String>.from(
                  (map['author_names']),
                ),
      publishedYear: map['first_publish_year'],
      status: false,
      coverId: map['cover_id'] != null ? map['cover_id'] as int : null,
    );
  }
}
