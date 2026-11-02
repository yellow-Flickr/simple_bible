import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/bible_reader/application/scripture_service.dart';
import 'package:simple_bible/bible_reader/data/local_scripture_repository.dart';
import 'package:simple_bible/bible_reader/data/scripture_data_source.dart' show scriptureDataProvider;
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/domain/scripture_repository.dart';
import 'package:simple_bible/shared/configs/objectbox.dart';

final scriptureRepositoryProvider = Provider<ScriptureRepository>((ref) {
  final store = ref.watch(objectBoxProvider).objStore;
  return LocalScriptureRepository(store);
});

final scriptureServiceProvider = Provider<ScriptureService>(
  (ref) => ScriptureService(
    ref.watch(scriptureRepositoryProvider),
    ref.watch(scriptureDataProvider),
  ),
);

class ScriptureInitializationController extends AsyncNotifier<void> {
  @override
  Future<void> build() {
    return ref.watch(scriptureServiceProvider).initialize();
  }
}

final scriptureInitializationProvider =
    AsyncNotifierProvider<ScriptureInitializationController, void>(
  ScriptureInitializationController.new,
);

/// The installed versions. Invalidate it after installing or removing one.
final installedVersionsProvider = Provider<List<Versions>>((ref) {
  // Recompute once the bundled versions have been stored at startup.
  ref.watch(scriptureInitializationProvider);
  return ref.watch(scriptureServiceProvider).getVersions();
});
