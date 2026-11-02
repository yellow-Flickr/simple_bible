import 'package:simple_bible/bible_reader/domain/scripture_models.dart';

abstract interface class ScriptureRepository {
  List<Versions> getAll();

  Versions? getById(int id);

  Future<void> saveAll(List<Versions> versions);

  /// Saves [version], replacing any stored version with the same id together
  /// with its books, chapters and verses.
  Future<void> install(Versions version);

  /// Deletes the version with [id] and its books, chapters and verses.
  void remove(int id);
}

abstract interface class ScriptureAssetSource {
  Future<List<Versions>> loadLocalScriptures();
}
