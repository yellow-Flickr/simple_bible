import 'package:simple_bible/notes/domain/notes.dart';
import 'package:simple_bible/notes/domain/notes_repository.dart';

class NotesService {
  const NotesService(this._repository);

  final NotesRepository _repository;

  List<Notes> loadNotes() {
    final notes = [..._repository.getAll()];
    notes.sort(
      (a, b) => DateTime.parse(b.lastModified)
          .compareTo(DateTime.parse(a.lastModified)),
    );
    return notes;
  }

  Future<void> saveNote(Notes note) => _repository.save(note);
}
