import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/objectbox.g.dart';

/// Every stored verse of one translation, for searching.
abstract interface class VerseSource {
  List<Verse> versesOf(String translationId);
}

class LocalVerseSource implements VerseSource {
  LocalVerseSource(Store store) : _box = store.box<Verse>();

  final Box<Verse> _box;

  @override
  List<Verse> versesOf(String translationId) {
    final query = _box.query(Verse_.translationId.equals(translationId)).build();
    try {
      return query.find()
        ..sort((a, b) {
          final byBook = a.bookId.compareTo(b.bookId);
          if (byBook != 0) return byBook;
          final byChapter = a.chapter.compareTo(b.chapter);
          return byChapter != 0 ? byChapter : a.verse.compareTo(b.verse);
        });
    } finally {
      query.close();
    }
  }
}
