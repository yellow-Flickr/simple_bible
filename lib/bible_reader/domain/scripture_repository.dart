import 'package:simple_bible/bible_reader/domain/scripture_models.dart';

abstract interface class ScriptureRepository {
  List<Versions> getAll();

  Versions? getById(int id);

  Future<void> saveAll(List<Versions> versions);
}

abstract interface class ScriptureAssetSource {
  Future<List<Versions>> loadLocalScriptures();
}
