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

  group('Quotation.tryParse', () {
    final version = _version();

    test('parses a single verse with 1-based numbers', () {
      final quotation = Quotation.tryParse('John 3:16', version)!;

      expect(quotation.bookId, 4);
      expect(quotation.bookName, 'John');
      expect(quotation.chapter, 3);
      expect(quotation.fromVerse, 16);
      expect(quotation.toVerse, [16]);
      expect(quotation.versionId, 100);
    });

    test('round-trips the quotation format', () {
      final quotation = Quotation.tryParse('Genesis 1:1-6, 11-13', version)!;

      expect(quotation.toVerse, [1, 2, 3, 4, 5, 6, 11, 12, 13]);
      expect(quotation.quotation, 'Genesis 1:1-6, 11-13');
    });

    test('parses numbered books, spacing and case variations', () {
      for (final input in ['1 John 1:9', '1john 1:9', ' 1 JOHN 1 : 9 ']) {
        final quotation = Quotation.tryParse(input, version);
        expect(quotation?.bookName, '1 John', reason: input);
        expect(quotation?.fromVerse, 9, reason: input);
      }
    });

    test('parses a chapter-only reference as starting at verse 1', () {
      final quotation = Quotation.tryParse('Psalms 3', version)!;

      expect(quotation.chapter, 3);
      expect(quotation.fromVerse, 1);
      expect(quotation.toVerse, isEmpty);
    });

    test('accepts unambiguous prefixes and rejects ambiguous ones', () {
      expect(Quotation.tryParse('Gen 1:1', version)?.bookName, 'Genesis');
      expect(Quotation.tryParse('Psalm 1:1', version)?.bookName, 'Psalms');
      expect(Quotation.tryParse('J 1:1', version), isNull);
    });

    test('prefers an exact name over a longer prefix match', () {
      expect(Quotation.tryParse('John 1:1', version)?.bookName, 'John');
    });

    test('matches either part of a parenthetical book name', () {
      final twi = _version(names: ['1 Mose (Gyenesis)', 'Ɛsra']);

      expect(Quotation.tryParse('Gyenesis 1:1', twi)?.bookId, 1);
      expect(Quotation.tryParse('1 Mose 1:1', twi)?.bookId, 1);
      expect(Quotation.tryParse('Esra 1:1', twi)?.bookId, 2);
    });

    test('rejects malformed or out-of-range references', () {
      for (final input in [
        '',
        '3:16',
        'John',
        'Unknown 1:1',
        'John 0:1',
        'John 4:1',
        'John 3:0',
        'John 3:31',
        'John 3:5-2',
        'John 3:1-999999999',
        'John 3:1,,2',
      ]) {
        expect(Quotation.tryParse(input, version), isNull, reason: input);
      }
    });
  });

  test('toReaderQuotation converts 1-based numbers to 0-based indexes', () {
    final reader = Quotation.tryParse('John 3:16-17', _version())!
        .toReaderQuotation();

    expect(reader.bookId, 3);
    expect(reader.chapter, 2);
    expect(reader.fromVerse, 15);
    expect(reader.toVerse, [15, 16]);
  });
}

/// Every book has 3 chapters of 30 verses.
Versions _version({
  List<String> names = const ['Genesis', 'Psalms', '1 John', 'John', 'Jude'],
}) {
  final version = Versions(id: 100, versionName: 'Test');
  for (final (index, name) in names.indexed) {
    final verses = [
      for (var chapter = 1; chapter <= 3; chapter++)
        for (var verse = 1; verse <= 30; verse++)
          Verse(
            id: verse,
            bookId: index + 1,
            chapter: chapter,
            verse: verse,
            text: 'Verse $verse',
            translationId: 'TEST',
            bookName: name,
            testament: 'Testament',
          ),
    ];
    version.books.add(Book.fromVerses(verses));
  }
  return version;
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
