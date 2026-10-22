import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/notes/application/notes_service.dart';
import 'package:simple_bible/notes/domain/notes.dart';
import 'package:simple_bible/notes/domain/notes_repository.dart';

void main() {
  group('NotesService', () {
    test('loads notes newest first and saves without duplicating an edit',
        () async {
      final repository = _FakeNotesRepository([
        _note(id: 'older', lastModified: '2024-01-01T00:00:00.000'),
        _note(id: 'newer', lastModified: '2024-01-02T00:00:00.000'),
      ]);
      final service = NotesService(repository);

      final initial = service.loadNotes();
      expect(initial.map((note) => note.id), ['newer', 'older']);

      await service.saveNote(
        _note(
          id: 'older',
          lastModified: '2024-01-03T00:00:00.000',
          title: 'Updated',
        ),
      );

      final updated = service.loadNotes();
      expect(updated.map((note) => note.id), ['older', 'newer']);
      expect(updated.first.title, 'Updated');
      expect(repository.savedNotes, hasLength(1));
    });

    test('keeps the loaded state when persistence fails', () async {
      final repository = _FakeNotesRepository([
        _note(id: 'existing', lastModified: '2024-01-01T00:00:00.000'),
      ])
        ..failOnSave = true;
      final service = NotesService(repository);

      await expectLater(
        service.saveNote(
          _note(id: 'new', lastModified: '2024-01-02T00:00:00.000'),
        ),
        throwsA(isA<StateError>()),
      );

      expect(service.loadNotes().map((note) => note.id), ['existing']);
    });
  });
}

Notes _note({
  required String id,
  required String lastModified,
  String title = 'Note',
}) {
  return Notes(
    id: id,
    createdAt: lastModified,
    lastModified: lastModified,
    title: title,
    content: 'Body',
  );
}

class _FakeNotesRepository implements NotesRepository {
  _FakeNotesRepository(this._notes);

  final List<Notes> _notes;
  final List<Notes> savedNotes = [];
  bool failOnSave = false;

  @override
  List<Notes> getAll() => [..._notes];

  @override
  bool isEmpty() => _notes.isEmpty;

  @override
  void saveAll(List<Notes> notes) {
    for (final note in notes) {
      _notes.removeWhere((existing) => existing.id == note.id);
      _notes.add(note);
    }
  }

  @override
  Future<void> save(Notes note) async {
    if (failOnSave) throw StateError('Storage unavailable');
    savedNotes.add(note);
    _notes.removeWhere((existing) => existing.id == note.id);
    _notes.add(note);
  }

  @override
  void clear() => _notes.clear();

  @override
  void deleteById(String id) {
    _notes.removeWhere((note) => note.id == id);
  }

  @override
  List<Notes> search(String term) => _notes
      .where((note) =>
          note.title.toLowerCase().contains(term.toLowerCase()) ||
          note.content.toLowerCase().contains(term.toLowerCase()))
      .toList();
}
