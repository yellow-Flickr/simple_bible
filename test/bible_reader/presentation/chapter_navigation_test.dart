import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_screen_controller.dart';

void main() {
  group('adjacentChapterPosition', () {
    final version = _version();

    test('moves between chapters in the same book', () {
      expect(
        adjacentChapterPosition(
          version,
          bookIndex: 0,
          chapterIndex: 0,
          direction: 1,
        ),
        (bookIndex: 0, chapterIndex: 1),
      );
      expect(
        adjacentChapterPosition(
          version,
          bookIndex: 0,
          chapterIndex: 1,
          direction: -1,
        ),
        (bookIndex: 0, chapterIndex: 0),
      );
    });

    test('moves forward to the first chapter of the next book', () {
      expect(
        adjacentChapterPosition(
          version,
          bookIndex: 0,
          chapterIndex: 1,
          direction: 1,
        ),
        (bookIndex: 1, chapterIndex: 0),
      );
    });

    test('moves backward to the last chapter of the previous book', () {
      expect(
        adjacentChapterPosition(
          version,
          bookIndex: 1,
          chapterIndex: 0,
          direction: -1,
        ),
        (bookIndex: 0, chapterIndex: 1),
      );
    });

    test('skips books without chapters when crossing a book boundary', () {
      final versionWithEmptyBook = Versions(
        id: 100,
        versionName: 'Test',
      )..books.addAll([
          _book('First', [1]),
          _book('Empty', []),
          _book('Last', [1]),
        ]);

      expect(
        adjacentChapterPosition(
          versionWithEmptyBook,
          bookIndex: 0,
          chapterIndex: 0,
          direction: 1,
        ),
        (bookIndex: 2, chapterIndex: 0),
      );
    });

    test('does not wrap at either end of the Bible', () {
      expect(
        adjacentChapterPosition(
          version,
          bookIndex: 0,
          chapterIndex: 0,
          direction: -1,
        ),
        isNull,
      );
      expect(
        adjacentChapterPosition(
          version,
          bookIndex: 1,
          chapterIndex: 0,
          direction: 1,
        ),
        isNull,
      );
    });

    test('rejects invalid directions and positions', () {
      expect(
        () => adjacentChapterPosition(
          version,
          bookIndex: 0,
          chapterIndex: 0,
          direction: 0,
        ),
        throwsArgumentError,
      );
      expect(
        adjacentChapterPosition(
          version,
          bookIndex: -1,
          chapterIndex: 0,
          direction: 1,
        ),
        isNull,
      );
      expect(
        adjacentChapterPosition(
          version,
          bookIndex: 0,
          chapterIndex: 2,
          direction: 1,
        ),
        isNull,
      );
    });
  });
}

Versions _version() {
  final version = Versions(id: 100, versionName: 'Test');
  version.books.addAll([
    _book('First', [1, 2]),
    _book('Second', [1]),
  ]);
  return version;
}

Book _book(String name, List<int> chapterNumbers) {
  final book = Book(
    translationId: 'TEST',
    name: name,
    testament: 'Testament',
  );
  book.chapters.addAll([
    for (final chapterNumber in chapterNumbers)
      Chapter(
        id: chapterNumber,
        chapter: chapterNumber,
        translationId: 'TEST',
        testament: 'Testament',
      ),
  ]);
  return book;
}
