import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:simple_bible/topics/domain/topic.dart';

class TopicsAssetSource {
  const TopicsAssetSource({this.assetPath = 'asset/topics.json'});

  final String assetPath;

  Future<List<Topic>> loadTopics() async {
    final jsonString = await rootBundle.loadString(assetPath);
    // The file is ~1.5 MB, so decode it off the UI isolate.
    final (topics, skipped) = await compute(parseTopics, jsonString);
    if (skipped.isNotEmpty) {
      developer.log(
        'Skipped ${skipped.length} unparseable topic references: '
        '${skipped.take(5).join(', ')}',
        name: 'TopicsAssetSource',
      );
    }
    return topics;
  }
}

/// Parses the topics JSON, sorted by name. Returns the topics and the
/// references that were dropped because their book or verses didn't parse.
(List<Topic>, List<String>) parseTopics(String jsonString) {
  final json = jsonDecode(jsonString);
  if (json is! Map<String, dynamic> || json['topics'] is! List) {
    throw const FormatException('topics.json: expected a "topics" list.');
  }

  final skipped = <String>[];
  final topics = <Topic>[];
  for (final topic in (json['topics'] as List).cast<Map<String, dynamic>>()) {
    final references = <TopicReference>[];
    for (final verse in (topic['verses'] as List).cast<Map<String, dynamic>>()) {
      final reference = _parseReference(verse);
      if (reference == null) {
        skipped.add('${verse['reference']}');
      } else {
        references.add(reference);
      }
    }
    topics.add(Topic(
      slug: topic['slug'] as String,
      name: topic['name'] as String,
      relatedSlugs: List<String>.from(topic['related_topics'] ?? const []),
      references: references,
    ));
  }
  topics.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  return (topics, skipped);
}

TopicReference? _parseReference(Map<String, dynamic> verse) {
  final bookNumber = canonicalBookNumber('${verse['book']}');
  final range = parseVerseRange('${verse['verses']}');
  final chapter = verse['chapter'];
  if (bookNumber == null || range == null || chapter is! int || chapter < 1) {
    return null;
  }
  return TopicReference(
    bookNumber: bookNumber,
    chapter: chapter,
    fromVerse: range.$1,
    toVerse: range.$2,
    otherTopicSlugs: List<String>.from(verse['other_topics'] ?? const []),
  );
}
