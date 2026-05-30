import 'package:simple_bible/notes/domain/notes.dart';
import 'package:simple_bible/objectbox.g.dart';

class NotesRepository {
  final Box<Notes> _box;

  NotesRepository(Store store) : _box = store.box<Notes>();

  // Read
  List<Notes> getAll() => _box.getAll();

  bool isEmpty() => _box.count() == 0;

  // Write
  void saveAll(List<Notes> loans) {
    _box.putMany(loans);
  }

  void save(Notes loan) {
    _box.put(loan);
  }

  // Delete
  void clear() => _box.removeAll();

  void deleteById(String remoteId) {
    final entity = _box.query(Notes_.id.equals(remoteId)).build().findFirst();
    if (entity != null) _box.remove(entity.uid ?? 0);
  }

  List<Notes> search(String term) {
    if (term.isEmpty) return [];

    final condition = Notes_.content
        .contains(term, caseSensitive: false)
        .or(Notes_.title.contains(term, caseSensitive: false));
    // add more fields as needed

    return _box.query(condition).build().find();
  }
}
