import 'package:simple_bible/version_store/domain/catalogue.dart';

abstract interface class CatalogueRepository {
  /// Fetches the latest catalogue and keeps a copy for offline use.
  Future<Catalogue> fetch();

  /// The last catalogue fetched successfully, if any.
  Catalogue? cached();
}
