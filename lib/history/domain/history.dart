import 'package:objectbox/objectbox.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';

@Entity()
class History {
  @Id()
  int? uid;

  int versionId;
  int bookId;
  int chapter;
  int fromVerse;
  String dateTime;

  History({
    this.uid,
    this.versionId = 100,
    this.bookId = 0,
    this.chapter = 0,
    this.fromVerse = 0,
    required this.dateTime,
  });

  Quotation? fromHistory() => Quotation(
        versionId: versionId,
        bookId: bookId,
        chapter: chapter,
        fromVerse: fromVerse,
      );
}
