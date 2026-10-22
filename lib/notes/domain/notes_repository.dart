import 'package:simple_bible/notes/domain/notes.dart';

abstract interface class NotesRepository {
  List<Notes> getAll();

  bool isEmpty();

  void saveAll(List<Notes> notes);

  Future<void> save(Notes note);

  void clear();

  void deleteById(String id);

  List<Notes> search(String term);
}
