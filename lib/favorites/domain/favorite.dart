import 'package:objectbox/objectbox.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';

@Entity()
class Favorite extends Quotation {
  @Id()
  int? uid;

  final int date;
  // String? bookTag;

  Favorite(
      {super.bookId,
      super.chapter,
      super.text,
      super.verse,
      super.versionId,
      required this.date});
}
