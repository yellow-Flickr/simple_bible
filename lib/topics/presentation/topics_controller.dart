import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureInitializationProvider, scriptureServiceProvider;
import 'package:simple_bible/reflections/presentation/reflections_controller.dart';
import 'package:simple_bible/topics/application/topics_service.dart';
import 'package:simple_bible/topics/data/topics_asset_source.dart';
import 'package:simple_bible/topics/domain/topic.dart';
import 'package:simple_bible/user_space/application/user_space_service.dart';

final topicsServiceProvider = Provider<TopicsService>(
  (ref) => TopicsService(const TopicsAssetSource()),
);

final topicsProvider = FutureProvider<List<Topic>>(
  (ref) => ref.watch(topicsServiceProvider).loadTopics(),
);

/// Random topics for Home, picked once per app launch.
final homeTopicSampleProvider = FutureProvider<List<Topic>>((ref) async {
  final topics = await ref.watch(topicsProvider.future);
  return ref.read(topicsServiceProvider).sample(topics);
});

/// The passages of the topic with [slug] in the app's current version.
final topicVersesProvider =
    FutureProvider.autoDispose.family<List<TopicVerse>, String>(
  (ref, slug) async {
    final topics = await ref.watch(topicsProvider.future);
    await ref.watch(scriptureInitializationProvider.future);
    final versionId = ref.watch(preferredVersionIdProvider);
    final version = ref.read(scriptureServiceProvider).getVersion(versionId);
    final topic = topics.firstWhere((t) => t.slug == slug);
    return ref
        .read(topicsServiceProvider)
        .versesFor(topic, version, allTopics: topics);
  },
);

/// Today's verse in the app's version: the passage of today's reflection,
/// or a passage picked from the topics when there is no reflection.
final dailyVerseProvider = FutureProvider.autoDispose<TopicVerse?>((ref) async {
  final topics = await ref.watch(topicsProvider.future);
  final reflection = await ref.watch(todayReflectionProvider.future);
  await ref.watch(scriptureInitializationProvider.future);
  final versionId = ref.watch(preferredVersionIdProvider);
  final version = ref.read(scriptureServiceProvider).getVersion(versionId);
  final service = ref.read(topicsServiceProvider);

  if (reflection != null) {
    final verse = service.resolveReference(reflection.reference, version,
        allTopics: topics);
    if (verse != null) return verse;
  }
  return service.dailyVerse(topics, version, DateTime.now());
});
