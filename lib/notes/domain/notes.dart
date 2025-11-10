import 'package:objectbox/objectbox.dart';

import 'package:simple_bible/bible_reader/domain/scripture_models.dart';

@Entity()
class Notes {
  @Id()
  int? uid;
  @Unique(onConflict: ConflictStrategy.replace)
  final int id;
  final String createdAt;
  final String lastModified;
  final String title;
  final String content;
  final List<Quotation> reference;

  Notes({
    required this.id,
    required this.createdAt,
    required this.lastModified,
    required this.title,
    required this.content,
    required this.reference,
  });
  // String? bookTag;

  // factory Favorite.fromJson(Map<String, dynamic> json) {
  //   final version = Favorite(date:   json['createdAt'] != null ? DateTime .parse(json['createdAt']) : null,);

  //   // Add books to the ToMany relationship
  //   final verseList =
  //       List<Verse>.from(json["version"].map((x) => Verse.fromJson(x)));

  //   final books = List<Book>.from(verseList
  //       .map((element) => element.bookId)
  //       .toSet()
  //       .map((e) => Book.fromVerses(
  //           verseList.where(((vers) => vers.bookId == e)).toList())));

  //   version.books.addAll(books);

  //   return version;
  // }
}
