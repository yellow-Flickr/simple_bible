import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/notes/domain/notes.dart';
import 'package:simple_bible/search/application/search_service.dart';
import 'package:simple_bible/search/data/verse_source.dart';
import 'package:simple_bible/search/domain/recent_search.dart';
import 'package:simple_bible/search/domain/search_query.dart';
import 'package:simple_bible/topics/domain/topic.dart';

void main() {
  group('VerseIndex.search', () {
    final index = VerseIndex([
      _verse(1, 1, 1, 'In the beginning God created the heaven'),
      _verse(19, 23, 1, 'The LORD is my shepherd'),
      _verse(43, 3, 16, 'For God so loved the world'),
      _verse(62, 4, 8, 'God is love'),
    ]);

    List<int> books(VerseResults r) => [for (final h in r.hits) h.verse.bookId];

    test('finds matches in Bible order with highlights', () {
      final result = index.search(SearchQuery.parse('god'));
      expect(books(result), [1, 43, 62]);
      expect(result.total, 3);
      expect(result.hits.first.highlights, [(17, 20)]);
    });

    test('limits to a testament or a book', () {
      final query = SearchQuery.parse('god');
      expect(books(index.search(query, scope: const OldTestament())), [1]);
      expect(books(index.search(query, scope: const NewTestament())), [43, 62]);
      expect(books(index.search(query, scope: const SingleBook(62))), [62]);
    });

    test('caps the hits but still counts every match', () {
      final result = index.search(SearchQuery.parse('god'), limit: 2);
      expect(result.hits, hasLength(2));
      expect(result.total, 3);
    });

    test('returns nothing for an empty query', () {
      expect(index.search(SearchQuery.parse('')).total, 0);
    });
  });

  group('recent searches', () {
    late _FakeRecent repo;
    late SearchService service;

    setUp(() {
      repo = _FakeRecent();
      service = SearchService(_FakeVerses(), repo, maxRecent: 3);
    });

    DateTime at(int minute) => DateTime(2026, 1, 1, 9, minute);

    test('are newest first and move to the top when repeated', () {
      service.addRecent('love', now: at(1));
      service.addRecent('peace', now: at(2));
      service.addRecent('LOVE ', now: at(3));
      expect(service.recentSearches(), ['LOVE', 'peace']);
    });

    test('keep only the newest few and ignore blank or one-letter input', () {
      for (final (i, q) in ['a', ' ', 'one', 'two', 'three', 'four'].indexed) {
        service.addRecent(q, now: at(i));
      }
      expect(service.recentSearches(), ['four', 'three', 'two']);
      expect(repo.items, hasLength(3));
    });

    test('can be cleared', () {
      service.addRecent('grace', now: at(1));
      service.clearRecent();
      expect(service.recentSearches(), isEmpty);
    });
  });

  test('matchTopics puts names that start with the text first', () {
    final topics = [_topic('Faithfulness'), _topic('Faith'), _topic('Hope')];
    expect(matchTopics(topics, 'fai').map((t) => t.name), ['Faith', 'Faithfulness']);
    expect(matchTopics(topics, 'h'), isEmpty);
  });

  test('matchNotes searches titles and text, newest first', () {
    final notes = [
      _note('Sunday', 'Grace and truth', '2026-01-01'),
      _note('Grace notes', 'misc', '2026-02-01'),
      _note('Other', 'nothing here', '2026-03-01'),
    ];
    expect(matchNotes(notes, SearchQuery.parse('grace')).map((n) => n.title),
        ['Grace notes', 'Sunday']);
  });

  test('searching the full KJV is fast and finds a known phrase', () {
    final json = jsonDecode(File('asset/kjv.json').readAsStringSync());
    final verses = [
      for (final v in json['version'] as List) Verse.fromJson(v),
    ];
    final watch = Stopwatch()..start();
    final index = VerseIndex(verses);
    final built = watch.elapsedMilliseconds;
    final result = index.search(SearchQuery.parse('"only begotten son"'));
    final searched = watch.elapsedMilliseconds - built;

    expect(
      result.hits.map((h) => '${h.verse.bookId} ${h.verse.chapter}:${h.verse.verse}'),
      contains('43 3:16'),
    );
    // Generous bounds for a debug VM; a release build is much faster.
    expect(built, lessThan(3000));
    expect(searched, lessThan(1000));
    // ignore: avoid_print
    print('KJV index ${verses.length} verses: build ${built}ms, search ${searched}ms');
  });
}

Verse _verse(int book, int chapter, int verse, String text) => Verse(
      id: verse,
      bookId: book,
      chapter: chapter,
      verse: verse,
      text: text,
      translationId: 'TEST',
      bookName: 'Book $book',
      testament: book <= 39 ? 'OT' : 'NT',
    );

Topic _topic(String name) =>
    Topic(slug: name.toLowerCase(), name: name, relatedSlugs: const [], references: const []);

Notes _note(String title, String content, String modified) => Notes(
      id: title,
      createdAt: modified,
      lastModified: modified,
      title: title,
      content: content,
    );

class _FakeVerses implements VerseSource {
  @override
  List<Verse> versesOf(String translationId) => const [];
}

class _FakeRecent implements RecentSearchRepository {
  final items = <RecentSearch>[];
  var _nextId = 1;

  @override
  List<RecentSearch> getAll() => [...items];

  @override
  void save(RecentSearch search) {
    search.uid ??= _nextId++;
    items
      ..removeWhere((r) => r.uid == search.uid)
      ..add(search);
  }

  @override
  void removeMany(List<int> uids) => items.removeWhere((r) => uids.contains(r.uid));
}
