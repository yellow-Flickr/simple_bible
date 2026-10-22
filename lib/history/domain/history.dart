import 'package:objectbox/objectbox.dart';

@Entity()
class History {
  @Id()
  int? uid;

  final int versionId;
  final int bookId;
  final int chapter;
  final int? fromVerse;
  final String dateTime;

  History({
    this.uid,
    required this.versionId,
    required this.bookId,
    required this.chapter,
    this.fromVerse,
    required this.dateTime,
  });
}
