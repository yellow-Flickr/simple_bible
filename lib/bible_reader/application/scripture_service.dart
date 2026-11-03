import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/domain/scripture_repository.dart';

typedef ResolvedReference = ({Versions version, Book book, Chapter chapter});

class ScriptureService {
  const ScriptureService(this._repository, this._dataSource);

  final ScriptureRepository _repository;
  final ScriptureAssetSource _dataSource;

  Future<void> initialize() async {
    if (_repository.getAll().isNotEmpty) return;

    final versions = await _dataSource.loadLocalScriptures();
    await _repository.saveAll(versions);
  }

  List<Versions> getVersions() => _repository.getAll();

  /// Saves a downloaded [version], replacing an older copy of it.
  Future<void> install(Versions version) => _repository.install(version);

  /// Deletes the version with [id]. The last installed version can't be
  /// removed, so the app always has something to read.
  void remove(String id) {
    final versions = _repository.getAll();
    if (versions.length <= 1 && versions.any((v) => v.id == id)) {
      throw StateError('The last installed version cannot be removed.');
    }
    _repository.remove(id);
  }

  Versions getVersion(String id) {
    final version = _repository.getById(id);
    if (version == null) {
      throw StateError('Scripture version $id is not available.');
    }
    return version;
  }

  /// Looks up the version, book and chapter that a reader [reference]
  /// (0-based indexes) points to. Returns null when the version is not stored
  /// or the book, chapter or starting verse is out of range, e.g. for history
  /// saved before the scripture data changed.
  ResolvedReference? resolve(Quotation reference) {
    final version = _repository.getById(reference.versionId);
    if (version == null) return null;

    final books = version.books;
    if (reference.bookId < 0 || reference.bookId >= books.length) return null;
    final book = books[reference.bookId];

    final chapters = book.chapters;
    if (reference.chapter < 0 || reference.chapter >= chapters.length) {
      return null;
    }
    final chapter = chapters[reference.chapter];

    if (reference.fromVerse < 0 ||
        reference.fromVerse >= chapter.verses.length) {
      return null;
    }

    return (version: version, book: book, chapter: chapter);
  }
}
