import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/search/domain/search_query.dart';

void main() {
  group('normalizeForSearch', () {
    test('folds case, Twi letters and accents without changing length', () {
      const text = 'Ɔdɔ ne Nyankopɔn, ÉLÈVE';
      final normalized = normalizeForSearch(text);
      expect(normalized, 'odo ne nyankopon, eleve');
      expect(normalized.length, text.length);
    });
  });

  group('SearchQuery', () {
    bool matches(String query, String text, {bool wholeWords = false}) =>
        SearchQuery.parse(query, wholeWords: wholeWords)
            .matches(normalizeForSearch(text));

    test('matches the start of words, ignoring case', () {
      expect(matches('love', 'He that loveth not'), isTrue);
      expect(matches('LOVE', 'God is love.'), isTrue);
      expect(matches('love', 'a glove'), isFalse);
    });

    test('whole words only matches the exact word', () {
      expect(matches('love', 'God is love.', wholeWords: true), isTrue);
      expect(matches('love', 'He that loveth', wholeWords: true), isFalse);
    });

    test('every word must appear, in any order', () {
      expect(matches('water living', 'he would have given thee living water'),
          isTrue);
      expect(matches('living bread', 'he would have given thee living water'),
          isFalse);
    });

    test('quoted text matches an exact phrase', () {
      expect(matches('"living water"', 'given thee living  water.'), isTrue);
      expect(matches('"water living"', 'given thee living water.'), isFalse);
      expect(matches('"living wat"', 'given thee living water.'), isFalse);
    });

    test('an unclosed quote still counts as a phrase', () {
      expect(SearchQuery.parse('"only begotten').phrases, ['only begotten']);
    });

    test('Twi can be searched without special letters', () {
      expect(matches('nyankopon', 'Na Nyankopɔn dɔɔ wiase'), isTrue);
    });

    test('is empty for blank or punctuation-only input', () {
      expect(SearchQuery.parse('  ').isEmpty, isTrue);
      expect(SearchQuery.parse('" ,; "').isEmpty, isTrue);
      expect(matches('', 'anything'), isFalse);
    });

    test('highlights are merged ranges valid in the original text', () {
      const text = 'Peace I leave with you, my peace I give unto you';
      final query = SearchQuery.parse('peace you');
      final ranges = query.highlights(normalizeForSearch(text));
      expect([for (final (s, e) in ranges) text.substring(s, e)],
          ['Peace', 'you', 'peace', 'you']);
    });
  });
}
