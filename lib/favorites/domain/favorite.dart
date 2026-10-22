import 'package:objectbox/objectbox.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';

@Entity()
class Favorite extends Quotation {
  @Id()
  int? uid;

  final int date;
  @override
  int chapter;
  @override
  int fromVerse;
  @override
  String text;
  @override
  int versionId;
  @override
  int bookId;
  // String? bookTag;

  Favorite({
    this.bookId = 0,
    this.chapter = 0,
    this.text = '',
    this.fromVerse = 0,
    this.versionId = 100,
    required this.date,
  }) : super(
          bookId: bookId,
          chapter: chapter,
          text: text,
          fromVerse: fromVerse,
          versionId: versionId,
        );

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
