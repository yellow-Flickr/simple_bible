import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/favorites/application/favorites_service.dart';
import 'package:simple_bible/favorites/domain/favorite.dart';

final favoritesServiceProvider = Provider<FavoritesService>(
  (ref) => throw UnimplementedError('FavoritesService must be provided.'),
);

class FavoritesController extends Notifier<List<Favorite>> {
  late FavoritesService _service;

  @override
  List<Favorite> build() {
    _service = ref.watch(favoritesServiceProvider);
    return _service.loadFavorites();
  }

  void toggleFavorites({
    required List<Verse> verses,
    required int versionId,
  }) {
    state = _service.toggleFavorites(verses: verses, versionId: versionId);
  }
}

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, List<Favorite>>(
  FavoritesController.new,
);
