import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/reflections/data/reflections_asset_source.dart';
import 'package:simple_bible/topics/data/topics_asset_source.dart';

void main() {
  test('every bundled reflection is complete and tied to its topic', () {
    final (reflections, skipped) =
        parseReflections(File('asset/reflections.json').readAsStringSync());
    final (topics, _) =
        parseTopics(File('asset/topics.json').readAsStringSync());
    final topicsBySlug = {for (final t in topics) t.slug: t};

    expect(reflections, isNotEmpty);
    expect(skipped, isEmpty);
    expect(reflections.map((r) => r.id).toSet(), hasLength(reflections.length));

    for (final r in reflections) {
      for (final field in [
        r.id,
        r.title,
        r.reflection,
        r.question,
        r.action,
        r.prayer
      ]) {
        expect(field.trim(), isNotEmpty, reason: r.id);
      }

      final topic = topicsBySlug[r.topicSlug];
      expect(topic, isNotNull, reason: '${r.id}: unknown topic ${r.topicSlug}');
      final ref = r.reference;
      expect(
        topic!.references.any((t) =>
            t.bookNumber == ref.bookNumber &&
            t.chapter == ref.chapter &&
            t.fromVerse == ref.fromVerse &&
            t.toVerse == ref.toVerse),
        isTrue,
        reason: '${r.id}: verse is not listed under ${r.topicSlug}',
      );
    }
  });

  test('skips entries with an unparseable reference', () {
    final (reflections, skipped) = parseReflections('''
      {"reflections": [
        {"id": "ok", "topic": "hope", "title": "T", "book": "Psalm",
         "chapter": 23, "verses": "1-2", "reflection": "R", "question": "Q",
         "action": "A", "prayer": "P"},
        {"id": "bad-book", "topic": "hope", "title": "T", "book": "Tobit",
         "chapter": 1, "verses": "1", "reflection": "R", "question": "Q",
         "action": "A", "prayer": "P"},
        {"id": "bad-verses", "topic": "hope", "title": "T", "book": "John",
         "chapter": 3, "verses": "5-2", "reflection": "R", "question": "Q",
         "action": "A", "prayer": "P"}
      ]}
    ''');

    expect(reflections.single.id, 'ok');
    expect(reflections.single.reference.bookNumber, 19);
    expect(skipped, ['bad-book', 'bad-verses']);
  });

  test('rejects a file without a reflections list', () {
    expect(() => parseReflections('{"topics": []}'), throwsFormatException);
  });
}
