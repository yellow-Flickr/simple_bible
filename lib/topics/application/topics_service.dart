import 'dart:math';

import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/topics/data/topics_asset_source.dart';
import 'package:simple_bible/topics/domain/topic.dart';

class TopicsService {
  TopicsService(this._source);

  final TopicsAssetSource _source;
  Future<List<Topic>>? _topics;

  /// Loads the catalog once; later calls reuse it. A failed load is not
  /// cached, so callers can retry.
  Future<List<Topic>> loadTopics() {
    return _topics ??= _source.loadTopics().catchError((Object error) {
      _topics = null;
      throw error;
    });
  }

  List<Topic> sample(List<Topic> topics, {int count = 6, Random? random}) {
    return ([...topics]..shuffle(random)).take(count).toList();
  }

  /// Resolves [topic]'s passages in [version], skipping any it doesn't
  /// contain. [allTopics] is used to look up each passage's other topics.
  List<TopicVerse> versesFor(
    Topic topic,
    Versions version, {
    List<Topic> allTopics = const [],
  }) {
    final topicsBySlug = {for (final t in allTopics) t.slug: t};
    return [
      for (final reference in topic.references)
        if (_resolve(reference, version, topicsBySlug) case final verse?)
          verse,
    ];
  }

  /// The verse of the day for [date]: a passage from any topic, the same
  /// for the whole day and different from day to day. Returns null only if
  /// no topic passage exists in [version].
  TopicVerse? dailyVerse(List<Topic> topics, Versions version, DateTime date) {
    // Many passages appear under several topics; count each once.
    final seen = <(int, int, int, int)>{};
    final references = [
      for (final topic in topics)
        for (final r in topic.references)
          if (seen.add((r.bookNumber, r.chapter, r.fromVerse, r.toVerse))) r,
    ];
    if (references.isEmpty) return null;

    final seed = date.year * 10000 + date.month * 100 + date.day;
    final start = Random(seed).nextInt(references.length);
    final topicsBySlug = {for (final t in topics) t.slug: t};
    for (var offset = 0; offset < references.length; offset++) {
      final reference = references[(start + offset) % references.length];
      final verse = _resolve(reference, version, topicsBySlug);
      if (verse != null) return verse;
    }
    return null;
  }

  TopicVerse? _resolve(
    TopicReference reference,
    Versions version,
    Map<String, Topic> topicsBySlug,
  ) {
    final verses = _lookUp(reference, version);
    if (verses == null) return null;

    return TopicVerse(
      quotation: Quotation.fromVerses(verses, versionId: version.id),
      verses: verses,
      otherTopics: [
        for (final slug in reference.otherTopicSlugs)
          if (topicsBySlug[slug] case final other?) other,
      ],
      translationId: verses.first.translationId,
    );
  }

  List<Verse>? _lookUp(TopicReference reference, Versions version) {
    final books = version.books;
    if (reference.bookNumber > books.length) return null;
    final chapters = books[reference.bookNumber - 1].chapters;
    if (reference.chapter > chapters.length) return null;

    final verses = chapters[reference.chapter - 1]
        .verses
        .where((v) =>
            v.verse >= reference.fromVerse && v.verse <= reference.toVerse)
        .toList();
    final expected = reference.toVerse - reference.fromVerse + 1;
    return verses.length == expected ? verses : null;
  }
}
