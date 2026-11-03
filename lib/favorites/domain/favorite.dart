import 'package:objectbox/objectbox.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';

@Entity()
class Favorite extends Quotation {
  @Id()
  int? uid;

  final int date;
  // @override
 @override
  final int chapter;
  // @override
@override
  final  int fromVerse;
  // @override
 @override
  final String text;
  // @override
 @override
  final String versionId;
  // @override
 @override
  final int bookId;
  // String? bookTag;

  Favorite({
     required this.bookId ,
     required this.chapter ,
     required this.text ,
     required this.fromVerse,
     required this.versionId ,
    required this.date,
    //  super.text,
    // required super.chapter,
    // required super.fromVerse,
    // required super.toVerse,
    // required super.versionId,
    // required super.bookId,
  })
  : super(
          bookId: bookId,
          chapter: chapter,
          text: text,
          fromVerse: fromVerse,
          versionId: versionId,
          toVerse: []
        )
  ;

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
