/// The newest version-file format this build can read. A catalogue entry with
/// a higher `minSchemaVersion` needs an app update.
const supportedSchemaVersion = 1;

/// The list of downloadable Bible versions, read from the catalogue repo.
class Catalogue {
  const Catalogue({
    required this.schemaVersion,
    required this.updatedAt,
    required this.entries,
  });

  factory Catalogue.fromJson(Map<String, dynamic> json) => Catalogue(
        schemaVersion: json['schemaVersion'] as int,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        entries: [
          for (final entry in json['versions'] as List)
            CatalogueEntry.fromJson(entry as Map<String, dynamic>),
        ],
      );

  final int schemaVersion;
  final DateTime updatedAt;
  final List<CatalogueEntry> entries;
}

/// One downloadable version. [id] matches [Versions.id] and is never reused.
class CatalogueEntry {
  const CatalogueEntry({
    required this.id,
    required this.translationId,
    required this.name,
    required this.abbreviation,
    required this.languageCode,
    required this.languageName,
    required this.revision,
    required this.url,
    required this.sizeBytes,
    required this.bookCount,
    required this.verseCount,
    required this.license,
    required this.minSchemaVersion,
  });

  factory CatalogueEntry.fromJson(Map<String, dynamic> json) {
    final language = json['language'] as Map<String, dynamic>;
    return CatalogueEntry(
      id: json['id'] as int,
      translationId: json['translationId'] as String,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String,
      languageCode: language['code'] as String,
      languageName: language['name'] as String,
      revision: json['revision'] as int,
      url: json['url'] as String,
      sizeBytes: json['sizeBytes'] as int,
      bookCount: json['bookCount'] as int,
      verseCount: json['verseCount'] as int,
      license: json['license'] as String,
      minSchemaVersion: json['minSchemaVersion'] as int? ?? 1,
    );
  }

  final int id;
  final String translationId;
  final String name;
  final String abbreviation;
  final String languageCode;
  final String languageName;

  /// Goes up whenever the text changes, so installed copies can be updated.
  final int revision;

  /// The version file, relative to the files base URL (or absolute).
  final String url;
  final int sizeBytes;
  final int bookCount;
  final int verseCount;
  final String license;
  final int minSchemaVersion;

  bool get isSupported => minSchemaVersion <= supportedSchemaVersion;

  Uri fileUri(Uri base) => base.resolve(url);
}

/// Where an entry stands against what is installed.
enum VersionAvailability {
  notInstalled,
  installed,
  updateAvailable,
  unsupported
}

/// [installedRevision] is null when the version isn't installed. Versions
/// saved before revisions existed store 0, which counts as revision 1.
VersionAvailability availabilityOf(
    CatalogueEntry entry, int? installedRevision) {
  if (installedRevision != null) {
    final revision = installedRevision < 1 ? 1 : installedRevision;
    return revision < entry.revision && entry.isSupported
        ? VersionAvailability.updateAvailable
        : VersionAvailability.installed;
  }
  return entry.isSupported
      ? VersionAvailability.notInstalled
      : VersionAvailability.unsupported;
}
