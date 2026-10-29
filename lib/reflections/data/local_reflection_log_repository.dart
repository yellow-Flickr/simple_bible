import 'package:simple_bible/objectbox.g.dart';
import 'package:simple_bible/reflections/domain/reflection_log.dart';

class LocalReflectionLogRepository implements ReflectionLogRepository {
  LocalReflectionLogRepository(Store store) : _box = store.box<ReflectionLog>();

  final Box<ReflectionLog> _box;

  @override
  List<ReflectionLog> getAll() => _box.getAll();

  @override
  Future<void> save(ReflectionLog log) async {
    await _box.putAsync(log);
  }
}
