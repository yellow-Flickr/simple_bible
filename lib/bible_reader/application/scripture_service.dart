import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/domain/scripture_repository.dart';

class ScriptureService {
  const ScriptureService(this._repository, this._dataSource);

  final ScriptureRepository _repository;
  final ScriptureAssetSource _dataSource;

  Future<void> initialize() async {
    if (_repository.getAll().isNotEmpty) return;

    final versions = await _dataSource.loadLocalScriptures();
    await _repository.saveAll(versions);
  }

  List<Versions> getVersions() => _repository.getAll();

  Versions getVersion(int id) {
    final version = _repository.getById(id);
    if (version == null) {
      throw StateError('Scripture version $id is not available.');
    }
    return version;
  }
}
