import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/data/scripture_repository.dart';
import 'package:simple_bible/configs/objectbox.dart';

class ScriptureService extends AsyncNotifier<void> {
  @override
  Future<void> build() {
    return initializeScriptures();
  }

  Future<void> initializeScriptures() async {
    // bool isNewInstance =
    //     ref.watch(objectBoxProvider).objStore.box<Versions>().isEmpty();
    if (!ref.watch(objectBoxProvider).objStore.box<Versions>().isEmpty()) {
      return;
    }

    await ref.watch(objectBoxProvider).objStore.box<Versions>().putManyAsync(
        await ref.read(scriptureDataProvider).loadLocalScriptures());

    return;
  }
}

final scriptureServiceProvider =
    AsyncNotifierProvider<ScriptureService, void>(() {
  return ScriptureService();
});

final versionProvider = Provider<Versions>((ref) =>
    (ref.watch(objectBoxProvider).objStore.box<Versions>().getAll().first));
    
    
final currentVersion = StateProvider<int>((ref) => 0);
