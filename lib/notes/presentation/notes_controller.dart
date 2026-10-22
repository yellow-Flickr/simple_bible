import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/notes/application/notes_service.dart';
import 'package:simple_bible/notes/domain/notes.dart';

final notesServiceProvider = Provider<NotesService>(
  (ref) => throw UnimplementedError('NotesService must be provided.'),
);

class NotesController extends AsyncNotifier<List<Notes>> {
  late NotesService _service;

  @override
  Future<List<Notes>> build() async {
    _service = ref.watch(notesServiceProvider);
    return _service.loadNotes();
  }

  Future<void> save(Notes note) async {
    await future;
    await _service.saveNote(note);
    state = AsyncData(_service.loadNotes());
  }
}

final notesControllerProvider =
    AsyncNotifierProvider<NotesController, List<Notes>>(NotesController.new);
