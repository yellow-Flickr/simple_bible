import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/domain/scripture_repository.dart';
import 'package:simple_bible/objectbox.g.dart';

class LocalScriptureRepository implements ScriptureRepository {
  LocalScriptureRepository(Store store) : _box = store.box<Versions>();

  final Box<Versions> _box;

  @override
  List<Versions> getAll() => _box.getAll();

  @override
  Versions? getById(int id) {
    final query = _box.query(Versions_.id.equals(id)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  @override
  Future<void> saveAll(List<Versions> versions) async {
    await _box.putManyAsync(versions);
  }
}
