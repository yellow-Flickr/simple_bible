import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/bible_reader/application/scripture_service.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/domain/scripture_repository.dart';

void main() {
  group('ScriptureService', () {
    test('loads and saves local versions when storage is empty', () async {
      final version = Versions(id: 'eng-kjv', versionName: 'KJV');
      final repository = _FakeScriptureRepository();
      var loadCount = 0;
      final service = ScriptureService(
        repository,
        _FakeScriptureAssetSource(() async {
          loadCount++;
          return [version];
        }),
      );

      await service.initialize();

      expect(loadCount, 1);
      expect(repository.savedVersions, [version]);
      expect(service.getVersion('eng-kjv'), same(version));
    });

    test('does not reload versions when storage already contains data',
        () async {
      final version = Versions(id: 'eng-kjv', versionName: 'KJV');
      final repository = _FakeScriptureRepository([version]);
      var loadCount = 0;
      final service = ScriptureService(
        repository,
        _FakeScriptureAssetSource(() async {
          loadCount++;
          return [];
        }),
      );

      await service.initialize();

      expect(loadCount, 0);
      expect(repository.savedVersions, isEmpty);
    });

    test('reports a missing stored version explicitly', () {
      final service = ScriptureService(
        _FakeScriptureRepository(),
        _FakeScriptureAssetSource(() async => []),
      );

      expect(() => service.getVersion('xxx-none'), throwsStateError);
    });

    test('install replaces a stored version with the same id', () async {
      final repository =
          _FakeScriptureRepository([Versions(id: 'eng-kjv', versionName: 'KJV')]);
      final service =
          ScriptureService(repository, _FakeScriptureAssetSource(() async => []));
      final update = Versions(id: 'eng-kjv', versionName: 'KJV', revision: 2);

      await service.install(update);

      expect(service.getVersions(), [update]);
    });

    test('removes a version while another is installed', () {
      final service = ScriptureService(
        _FakeScriptureRepository([
          Versions(id: 'eng-kjv', versionName: 'KJV'),
          Versions(id: 'twi-akna', versionName: 'Twi'),
        ]),
        _FakeScriptureAssetSource(() async => []),
      );

      service.remove('twi-akna');

      expect(service.getVersions().map((v) => v.id), ['eng-kjv']);
    });

    test('refuses to remove the last installed version', () {
      final service = ScriptureService(
        _FakeScriptureRepository([Versions(id: 'eng-kjv', versionName: 'KJV')]),
        _FakeScriptureAssetSource(() async => []),
      );

      expect(() => service.remove('eng-kjv'), throwsStateError);
      expect(service.getVersions(), hasLength(1));
    });

    group('resolve', () {
      final version = _versionWithVerses(chapters: 2, versesPerChapter: 3);
      final service = ScriptureService(
        _FakeScriptureRepository([version]),
        _FakeScriptureAssetSource(() async => []),
      );

      Quotation reference({
        String versionId = 'eng-kjv',
        int bookId = 0,
        int chapter = 0,
        int fromVerse = 0,
      }) =>
          Quotation(
            versionId: versionId,
            bookId: bookId,
            chapter: chapter,
            fromVerse: fromVerse,
            toVerse: [],
          );

      test('returns the version, book and chapter for a valid reference', () {
        final resolved = service.resolve(reference(chapter: 1, fromVerse: 2));

        expect(resolved?.version, same(version));
        expect(resolved?.book, same(version.books[0]));
        expect(resolved?.chapter, same(version.books[0].chapters[1]));
      });

      test('returns null for out-of-range references', () {
        for (final (label, invalid) in [
          ('unknown version', reference(versionId: 'xxx-none')),
          ('negative book', reference(bookId: -1)),
          ('book past end', reference(bookId: 1)),
          ('negative chapter', reference(chapter: -1)),
          ('chapter past end', reference(chapter: 2)),
          ('negative verse', reference(fromVerse: -1)),
          ('verse past end', reference(fromVerse: 3)),
        ]) {
          expect(service.resolve(invalid), isNull, reason: label);
        }
      });
    });
  });
}

Versions _versionWithVerses({
  required int chapters,
  required int versesPerChapter,
}) {
  final version = Versions(id: 'eng-kjv', versionName: 'KJV');
  version.books.add(Book.fromVerses([
    for (var chapter = 1; chapter <= chapters; chapter++)
      for (var verse = 1; verse <= versesPerChapter; verse++)
        Verse(
          id: verse,
          bookId: 1,
          chapter: chapter,
          verse: verse,
          text: 'Verse $verse',
          translationId: 'KJV',
          bookName: 'Genesis',
          testament: 'Old Testament',
        ),
  ]));
  return version;
}

class _FakeScriptureRepository implements ScriptureRepository {
  _FakeScriptureRepository([List<Versions>? versions])
      : _versions = versions ?? [];

  final List<Versions> _versions;
  final List<Versions> savedVersions = [];

  @override
  List<Versions> getAll() => [..._versions];

  @override
  Versions? getById(String id) {
    for (final version in _versions) {
      if (version.id == id) return version;
    }
    return null;
  }

  @override
  Future<void> saveAll(List<Versions> versions) async {
    savedVersions.addAll(versions);
    _versions.addAll(versions);
  }

  @override
  Future<void> install(Versions version) async {
    remove(version.id);
    _versions.add(version);
  }

  @override
  void remove(String id) => _versions.removeWhere((v) => v.id == id);
}

class _FakeScriptureAssetSource implements ScriptureAssetSource {
  const _FakeScriptureAssetSource(this.load);

  final Future<List<Versions>> Function() load;

  @override
  Future<List<Versions>> loadLocalScriptures() => load();
}
