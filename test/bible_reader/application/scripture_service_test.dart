import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/bible_reader/application/scripture_service.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/domain/scripture_repository.dart';

void main() {
  group('ScriptureService', () {
    test('loads and saves local versions when storage is empty', () async {
      final version = Versions(id: 100, versionName: 'KJV');
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
      expect(service.getVersion(100), same(version));
    });

    test('does not reload versions when storage already contains data',
        () async {
      final version = Versions(id: 100, versionName: 'KJV');
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

      expect(() => service.getVersion(404), throwsStateError);
    });
  });
}

class _FakeScriptureRepository implements ScriptureRepository {
  _FakeScriptureRepository([List<Versions>? versions])
      : _versions = versions ?? [];

  final List<Versions> _versions;
  final List<Versions> savedVersions = [];

  @override
  List<Versions> getAll() => [..._versions];

  @override
  Versions? getById(int id) {
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
}

class _FakeScriptureAssetSource implements ScriptureAssetSource {
  const _FakeScriptureAssetSource(this.load);

  final Future<List<Versions>> Function() load;

  @override
  Future<List<Versions>> loadLocalScriptures() => load();
}
