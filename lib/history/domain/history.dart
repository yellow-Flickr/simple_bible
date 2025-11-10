import 'package:objectbox/objectbox.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';

@Entity()
class History extends Quotation {
  @Id()
  int? uid;

  final String dateTime;
  // String? bookTag;

  History(
      {super.bookId,
      super.chapter,
      super.text,
      super.verse,
      super.versionId,
      required this.dateTime});

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
final List<History> historySamples = [
  History(
    bookId: 1,
    chapter: 1,
    verse: 1,
    text: "In the beginning, God created the heavens and the earth.",
    versionId: 100,
    dateTime: "20120227T132700",
  ),
  History(
    bookId: 1,
    chapter: 1,
    verse: 2,
    text: "Now the earth was formless and empty, darkness was over the surface of the deep.",
    versionId: 100,
    dateTime: "20120301T091500",
  ),
  History(
    bookId: 2,
    chapter: 3,
    verse: 16,
    text: "For God so loved the world that he gave his one and only Son.",
    versionId: 100,
    dateTime: "20120415T174530",
  ),
  History(
    bookId: 3,
    chapter: 5,
    verse: 12,
    text: "Blessed are the meek, for they will inherit the earth.",
    versionId: 100,
    dateTime: "20120520T083200",
  ),
  History(
    bookId: 4,
    chapter: 6,
    verse: 9,
    text: "The Lord is my shepherd, I lack nothing.",
    versionId: 100,
    dateTime: "20120610T223045",
  ),
];