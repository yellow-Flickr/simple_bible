import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:simple_bible/objectbox.g.dart';
import 'package:simple_bible/version_store/domain/cached_catalogue.dart';
import 'package:simple_bible/version_store/domain/catalogue.dart';
import 'package:simple_bible/version_store/domain/catalogue_repository.dart';

class RemoteCatalogueRepository implements CatalogueRepository {
  RemoteCatalogueRepository(this._dio, Store store, this._uri)
      : _box = store.box<CachedCatalogue>();

  final Dio _dio;
  final Box<CachedCatalogue> _box;
  final Uri _uri;

  @override
  Future<Catalogue> fetch() async {
    final response = await _dio.getUri<String>(
      _uri,
      options: Options(responseType: ResponseType.plain),
    );
    final text = response.data ?? '';
    // Parse before caching so a broken file never replaces a good copy.
    final catalogue = _parse(text);
    _box.removeAll();
    _box.put(CachedCatalogue(
      json: text,
      fetchedAt: DateTime.now().millisecondsSinceEpoch,
    ));
    return catalogue;
  }

  @override
  Catalogue? cached() {
    final cache = _box.getAll().firstOrNull;
    if (cache == null) return null;
    try {
      return _parse(cache.json);
    } on Object {
      return null;
    }
  }

  static Catalogue _parse(String text) =>
      Catalogue.fromJson(jsonDecode(text) as Map<String, dynamic>);
}
