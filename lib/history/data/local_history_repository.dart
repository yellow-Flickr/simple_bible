import 'package:simple_bible/history/domain/history.dart';
import 'package:simple_bible/history/domain/history_repository.dart';
import 'package:simple_bible/objectbox.g.dart';

class LocalHistoryRepository implements HistoryRepository {
  LocalHistoryRepository(Store store) : _box = store.box<History>();

  final Box<History> _box;

  @override
  List<History> getAll() => _box.getAll();

  @override
  Future<void> save(History history) async {
    await _box.putAsync(history);
  }
}
