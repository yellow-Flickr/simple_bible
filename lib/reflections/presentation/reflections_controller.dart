import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureInitializationProvider, scriptureServiceProvider;
import 'package:simple_bible/reflections/application/reflections_service.dart';
import 'package:simple_bible/reflections/data/local_reflection_log_repository.dart';
import 'package:simple_bible/reflections/data/reflections_asset_source.dart';
import 'package:simple_bible/reflections/domain/reflection.dart';
import 'package:simple_bible/shared/configs/objectbox.dart';
import 'package:simple_bible/topics/domain/topic.dart';
import 'package:simple_bible/topics/presentation/topics_controller.dart';
import 'package:simple_bible/user_space/application/user_space_service.dart';

final reflectionsServiceProvider = Provider<ReflectionsService>((ref) {
  final store = ref.watch(objectBoxProvider).objStore;
  return ReflectionsService(
    const ReflectionsAssetSource(),
    LocalReflectionLogRepository(store),
  );
});

/// Today's reflection. Reading it logs it in the history, so it is only
/// watched where the reflection is actually shown (Home).
final todayReflectionProvider = FutureProvider<Reflection?>(
  (ref) => ref.read(reflectionsServiceProvider).todayReflection(DateTime.now()),
);

/// Reflections shown so far, newest first, including today's.
final reflectionHistoryProvider =
    FutureProvider.autoDispose<List<ReflectionEntry>>((ref) async {
  await ref.watch(todayReflectionProvider.future);
  return ref.read(reflectionsServiceProvider).history();
});

/// The passage of [reflection] in the app's current version, or null if the
/// version doesn't contain it.
final reflectionVerseProvider =
    FutureProvider.autoDispose.family<TopicVerse?, Reflection>(
  (ref, reflection) async {
    final topics = await ref.watch(topicsProvider.future);
    await ref.watch(scriptureInitializationProvider.future);
    final versionId = ref.watch(preferredVersionIdProvider);
    final version = ref.read(scriptureServiceProvider).getVersion(versionId);
    return ref
        .read(topicsServiceProvider)
        .resolveReference(reflection.reference, version, allTopics: topics);
  },
);
