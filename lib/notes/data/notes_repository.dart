import 'package:simple_bible/notes/domain/notes.dart';
import 'package:simple_bible/notes/domain/notes_repository.dart';
import 'package:simple_bible/objectbox.g.dart';

class LocalNotesRepository implements NotesRepository {
  final Box<Notes> _box;

  LocalNotesRepository(Store store) : _box = store.box<Notes>();

  @override
  List<Notes> getAll() => _box.getAll();

  @override
  bool isEmpty() => _box.count() == 0;

  @override
  void saveAll(List<Notes> notes) {
    _box.putMany(notes);
  }

  @override
  Future<void> save(Notes note) async {
    await _box.putAsync(note);
  }

  @override
  void clear() => _box.removeAll();

  @override
  void deleteById(String id) {
    final query = _box.query(Notes_.id.equals(id)).build();
    try {
      final entity = query.findFirst();
      if (entity != null) _box.remove(entity.uid ?? 0);
    } finally {
      query.close();
    }
  }

  @override
  List<Notes> search(String term) {
    if (term.isEmpty) return [];

    final condition = Notes_.content
        .contains(term, caseSensitive: false)
        .or(Notes_.title.contains(term, caseSensitive: false));
    final query = _box.query(condition).build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }
}
