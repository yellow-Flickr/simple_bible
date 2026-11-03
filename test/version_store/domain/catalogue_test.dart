import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/version_store/domain/catalogue.dart';

Map<String, dynamic> entryJson({int revision = 2, int? minSchemaVersion}) => {
      'id': 'eng-asv',
      'translationId': 'ASV',
      'name': 'American Standard Version',
      'abbreviation': 'ASV',
      'language': {'code': 'en', 'name': 'English'},
      'revision': revision,
      'url': 'versions/asv/asv.v2.json',
      'sizeBytes': 10412345,
      'bookCount': 66,
      'verseCount': 31102,
      'license': 'Public Domain',
      if (minSchemaVersion != null) 'minSchemaVersion': minSchemaVersion,
    };

void main() {
  group('Catalogue.fromJson', () {
    test('reads the catalogue and its entries', () {
      final catalogue = Catalogue.fromJson({
        'schemaVersion': 1,
        'updatedAt': '2026-11-02T00:00:00Z',
        'versions': [entryJson()],
      });

      expect(catalogue.schemaVersion, 1);
      expect(catalogue.updatedAt, DateTime.utc(2026, 11, 2));
      final entry = catalogue.entries.single;
      expect(entry.id, 'eng-asv');
      expect(entry.languageName, 'English');
      expect(entry.minSchemaVersion, 1);
      expect(entry.isSupported, isTrue);
    });

    test('resolves relative and absolute file urls against the base', () {
      final base = Uri.parse('https://cdn.example.com/gh/me/repo@main/');
      final relative = CatalogueEntry.fromJson(entryJson());
      final absolute = CatalogueEntry.fromJson(
          {...entryJson(), 'url': 'https://other.example.com/asv.json'});

      expect(relative.fileUri(base).toString(),
          'https://cdn.example.com/gh/me/repo@main/versions/asv/asv.v2.json');
      expect(absolute.fileUri(base).toString(),
          'https://other.example.com/asv.json');
    });
  });

  group('availabilityOf', () {
    final entry = CatalogueEntry.fromJson(entryJson(revision: 2));

    test('not installed', () {
      expect(availabilityOf(entry, null), VersionAvailability.notInstalled);
    });

    test('installed at the latest revision', () {
      expect(availabilityOf(entry, 2), VersionAvailability.installed);
    });

    test('older installed revision has an update', () {
      expect(availabilityOf(entry, 1), VersionAvailability.updateAvailable);
    });

    test('rows saved before revisions count as revision 1', () {
      final first = CatalogueEntry.fromJson(entryJson(revision: 1));
      expect(availabilityOf(first, 0), VersionAvailability.installed);
    });

    test('a newer file format needs an app update', () {
      final newer = CatalogueEntry.fromJson(
          entryJson(minSchemaVersion: supportedSchemaVersion + 1));
      expect(availabilityOf(newer, null), VersionAvailability.unsupported);
      expect(availabilityOf(newer, 1), VersionAvailability.installed);
    });
  });
}
