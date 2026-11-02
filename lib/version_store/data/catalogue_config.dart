/// The version list, read straight from GitHub so changes show up within
/// minutes. Override with `--dart-define=CATALOGUE_URL=...`.
final catalogueUri = Uri.parse(const String.fromEnvironment(
  'CATALOGUE_URL',
  defaultValue:
      'https://raw.githubusercontent.com/yellow-Flickr/simple-bible-catalogue/main/catalogue.json',
));

/// Where entry `url`s are resolved. Version files go through the jsDelivr CDN,
/// which compresses them; their names include the revision, so a cached copy
/// is never stale. Override with `--dart-define=VERSION_FILES_URL=...`.
final versionFilesBaseUri = Uri.parse(const String.fromEnvironment(
  'VERSION_FILES_URL',
  defaultValue:
      'https://cdn.jsdelivr.net/gh/yellow-Flickr/simple-bible-catalogue@main/',
));
