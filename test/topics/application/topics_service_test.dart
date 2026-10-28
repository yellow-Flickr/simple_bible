import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/topics/application/topics_service.dart';
import 'package:simple_bible/topics/data/topics_asset_source.dart';
import 'package:simple_bible/topics/domain/topic.dart';

void main() {
  final service = TopicsService(const TopicsAssetSource());

  group('versesFor', () {
    final version = _version(['1 Mose', '2 Mose']);
    final faith = _topic('faith', 'Faith');

    test('resolves ranges with the version text and book name', () {
      final topic = _topic('hope', 'Hope', references: [
        const TopicReference(
          bookNumber: 2,
          chapter: 2,
          fromVerse: 3,
          toVerse: 4,
          otherTopicSlugs: ['faith', 'unknown'],
        ),
      ]);

      final verse = service
          .versesFor(topic, version, allTopics: [topic, faith])
          .single;

      expect(verse.quotation.quotation, '2 Mose 2:3-4');
      expect(verse.quotation.text, 'Verse 3 Verse 4');
      expect(verse.quotation.versionId, 200);
      expect(verse.verses.map((v) => v.verse), [3, 4]);
      expect(verse.otherTopics, [faith]);
      expect(verse.translationId, 'TEST');
    });

    test('skips references the version does not contain', () {
      final topic = _topic('hope', 'Hope', references: const [
        TopicReference(bookNumber: 3, chapter: 1, fromVerse: 1, toVerse: 1),
        TopicReference(bookNumber: 1, chapter: 4, fromVerse: 1, toVerse: 1),
        TopicReference(bookNumber: 1, chapter: 1, fromVerse: 5, toVerse: 6),
        TopicReference(bookNumber: 1, chapter: 1, fromVerse: 1, toVerse: 1),
      ]);

      final verses = service.versesFor(topic, version);

      expect(verses.map((v) => v.quotation.quotation), ['1 Mose 1:1']);
    });
  });

  group('dailyVerse', () {
    final version = _version(['Genesis', 'Exodus']);
    final topics = [
      for (var i = 0; i < 4; i++)
        _topic('t$i', 'Topic $i', references: [
          for (var verse = 1; verse <= 5; verse++)
            TopicReference(
              bookNumber: i.isEven ? 1 : 2,
              chapter: i + 1 > 3 ? 3 : i + 1,
              fromVerse: verse,
              toVerse: verse,
            ),
        ]),
    ];

    String? pick(DateTime date, [List<Topic>? from]) => service
        .dailyVerse(from ?? topics, version, date)
        ?.quotation
        .quotation;

    test('is the same all day', () {
      expect(pick(DateTime(2026, 10, 28, 0, 1)),
          pick(DateTime(2026, 10, 28, 23, 59)));
    });

    test('changes across days', () {
      final picks = {
        for (var day = 1; day <= 14; day++) pick(DateTime(2026, 11, day)),
      };
      expect(picks.length, greaterThan(1));
    });

    test('falls through to a passage the version contains', () {
      final onlyOneResolves = [
        _topic('x', 'X', references: const [
          TopicReference(bookNumber: 9, chapter: 1, fromVerse: 1, toVerse: 1),
          TopicReference(bookNumber: 1, chapter: 9, fromVerse: 1, toVerse: 1),
          TopicReference(bookNumber: 2, chapter: 1, fromVerse: 2, toVerse: 3),
        ]),
      ];
      for (var day = 1; day <= 5; day++) {
        expect(pick(DateTime(2026, 1, day), onlyOneResolves), 'Exodus 1:2-3');
      }
    });

    test('returns null when there are no passages', () {
      expect(pick(DateTime(2026), const []), isNull);
    });
  });

  group('sample', () {
    final topics = [
      for (var i = 0; i < 10; i++) _topic('t$i', 'Topic $i'),
    ];

    test('returns count distinct topics', () {
      final sample = service.sample(topics, random: Random(1));

      expect(sample, hasLength(6));
      expect(sample.toSet(), hasLength(6));
      expect(topics, containsAll(sample));
    });

    test('returns every topic when there are fewer than count', () {
      expect(service.sample(topics.take(3).toList()), hasLength(3));
    });
  });
}

Topic _topic(
  String slug,
  String name, {
  List<TopicReference> references = const [],
}) =>
    Topic(slug: slug, name: name, relatedSlugs: const [], references: references);

/// Each book has 3 chapters of 5 verses.
Versions _version(List<String> bookNames) {
  final version = Versions(id: 200, versionName: 'Test');
  for (final (index, name) in bookNames.indexed) {
    version.books.add(Book.fromVerses([
      for (var chapter = 1; chapter <= 3; chapter++)
        for (var verse = 1; verse <= 5; verse++)
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
    ]));
  }
  return version;
}
