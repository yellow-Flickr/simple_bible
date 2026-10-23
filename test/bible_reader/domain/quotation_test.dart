import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';

void main() {
  group('Quotation selection', () {
    test('formats consecutive and separate selected verses as a quotation', () {
      final quotation = Quotation.fromVerses([
        _verse(13),
        _verse(5),
        _verse(2),
        _verse(1),
        _verse(6),
        _verse(11),
        _verse(3),
        _verse(4),
        _verse(5),
        _verse(12),
      ], versionId: 101);

      expect(quotation.quotation, 'Genesis 1:1-6, 11-13');
      expect(
        quotation.text,
        'Verse 1 Verse 2 Verse 3 Verse 4 Verse 5 Verse 6 '
        'Verse 11 Verse 12 Verse 13',
      );
      expect(quotation.versionId, 101);
    });

    test('formats selected single verses without range delimiters', () {
      final quotation = Quotation.fromVerses([_verse(7), _verse(3)]);

      expect(quotation.quotation, 'Genesis 1:3, 7');
      expect(quotation.text, 'Verse 3 Verse 7');
    });

    test('rejects empty selections', () {
      expect(
        () => Quotation.fromVerses([]),
        throwsArgumentError,
      );
    });

    test('rejects selections spanning chapters', () {
      expect(
        () => Quotation.fromVerses([_verse(1), _verse(2, chapter: 2)]),
        throwsArgumentError,
      );
    });
  });
}

Verse _verse(int verse, {int chapter = 1}) => Verse(
      id: verse,
      bookId: 1,
      chapter: chapter,
      verse: verse,
      text: 'Verse $verse',
      translationId: 'KJV',
      bookName: 'Genesis',
      testament: 'Old Testament',
    );
