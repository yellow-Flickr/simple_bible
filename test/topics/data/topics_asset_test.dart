import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/topics/data/topics_asset_source.dart';

void main() {
  test('every reference in the bundled topics.json parses', () {
    final (topics, skipped) =
        parseTopics(File('asset/topics.json').readAsStringSync());

    expect(topics, hasLength(161));
    expect(skipped, isEmpty);
    expect(topics.expand((t) => t.references), hasLength(5211));

    final names = topics.map((t) => t.name.toLowerCase()).toList();
    expect(names, [...names]..sort());

    final slugs = topics.map((t) => t.slug).toSet();
    for (final topic in topics) {
      expect(slugs, containsAll(topic.relatedSlugs), reason: topic.slug);
    }
  });

  test('skips unparseable references and reports them', () {
    final (topics, skipped) = parseTopics('''
      {"topics": [{
        "slug": "hope", "name": "Hope", "related_topics": ["faith"],
        "verses": [
          {"reference": "Psalm 23:1", "book": "Psalm", "chapter": 23,
           "verses": "1-2", "other_topics": ["faith"]},
          {"reference": "Tobit 1:1", "book": "Tobit", "chapter": 1,
           "verses": "1", "other_topics": []}
        ]
      }]}
    ''');

    final reference = topics.single.references.single;
    expect(reference.bookNumber, 19);
    expect((reference.fromVerse, reference.toVerse), (1, 2));
    expect(reference.otherTopicSlugs, ['faith']);
    expect(skipped, ['Tobit 1:1']);
  });

  test('rejects a file without a topics list', () {
    expect(() => parseTopics('{"source": "x"}'), throwsFormatException);
  });
}
