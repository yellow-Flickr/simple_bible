import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/domain/scripture_repository.dart';
import 'package:simple_bible/objectbox.g.dart';

typedef _VersionContent = ({
  List<int> books,
  List<int> chapters,
  List<int> verses,
  int language,
});

class LocalScriptureRepository implements ScriptureRepository {
  LocalScriptureRepository(this._store) : _box = _store.box<Versions>();

  final Store _store;
  final Box<Versions> _box;

  @override
  List<Versions> getAll() => _box.getAll();

  @override
  Versions? getById(String id) {
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

  @override
  Future<void> install(Versions version) async {
    // Collect the old content first: the new version usually has the same
    // translation id, and its id replaces the old row but not its children.
    final stale = _contentOf(version.id);
    await _box.putAsync(version);
    if (stale != null) {
      _store.runInTransaction(TxMode.write, () => _removeContent(stale));
    }
  }

  @override
  void remove(String id) {
    final stale = _contentOf(id);
    _store.runInTransaction(TxMode.write, () {
      if (stale != null) _removeContent(stale);
      final query = _box.query(Versions_.id.equals(id)).build();
      try {
        query.remove();
      } finally {
        query.close();
      }
    });
  }

  /// Ids of the books, chapters, verses and language stored for version [id].
  /// The first three are found by translation id, which is unique per version.
  _VersionContent? _contentOf(String id) {
    final version = getById(id);
    final translationId = version?.books.firstOrNull?.translationId;
    if (translationId == null) return null;

    List<int> idsOf<T>(Condition<T> condition) {
      final query = _store.box<T>().query(condition).build();
      try {
        return query.findIds();
      } finally {
        query.close();
      }
    }

    return (
      books: idsOf(Book_.translationId.equals(translationId)),
      chapters: idsOf(Chapter_.translationId.equals(translationId)),
      verses: idsOf(Verse_.translationId.equals(translationId)),
      language: version!.language.targetId,
    );
  }

  void _removeContent(_VersionContent content) {
    _store.box<Verse>().removeMany(content.verses);
    _store.box<Chapter>().removeMany(content.chapters);
    _store.box<Book>().removeMany(content.books);
    if (content.language != 0) _store.box<Language>().remove(content.language);
  }
}
