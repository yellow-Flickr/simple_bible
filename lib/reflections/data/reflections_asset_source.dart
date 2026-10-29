import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:simple_bible/reflections/domain/reflection.dart';
import 'package:simple_bible/topics/domain/topic.dart';

class ReflectionsAssetSource {
  const ReflectionsAssetSource({this.assetPath = 'asset/reflections.json'});

  final String assetPath;

  Future<List<Reflection>> loadReflections() async {
    final (reflections, skipped) =
        parseReflections(await rootBundle.loadString(assetPath));
    if (skipped.isNotEmpty) {
      developer.log(
        'Skipped reflections with unparseable references: ${skipped.join(', ')}',
        name: 'ReflectionsAssetSource',
      );
    }
    return reflections;
  }
}

/// Parses the reflections JSON in file order. Returns the reflections and the
/// ids of entries dropped because their book or verses didn't parse.
(List<Reflection>, List<String>) parseReflections(String jsonString) {
  final json = jsonDecode(jsonString);
  if (json is! Map<String, dynamic> || json['reflections'] is! List) {
    throw const FormatException(
        'reflections.json: expected a "reflections" list.');
  }

  final reflections = <Reflection>[];
  final skipped = <String>[];
  for (final entry
      in (json['reflections'] as List).cast<Map<String, dynamic>>()) {
    final id = entry['id'] as String;
    final bookNumber = canonicalBookNumber('${entry['book']}');
    final range = parseVerseRange('${entry['verses']}');
    final chapter = entry['chapter'];
    if (bookNumber == null || range == null || chapter is! int || chapter < 1) {
      skipped.add(id);
      continue;
    }

    reflections.add(Reflection(
      id: id,
      topicSlug: entry['topic'] as String,
      title: entry['title'] as String,
      reference: TopicReference(
        bookNumber: bookNumber,
        chapter: chapter,
        fromVerse: range.$1,
        toVerse: range.$2,
      ),
      reflection: entry['reflection'] as String,
      question: entry['question'] as String,
      action: entry['action'] as String,
      prayer: entry['prayer'] as String,
    ));
  }
  return (reflections, skipped);
}
