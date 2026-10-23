import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/favorites/domain/favorite.dart';
import 'package:simple_bible/favorites/domain/favorites_repository.dart';

class FavoritesService {
  const FavoritesService(this._repository);

  final FavoritesRepository _repository;

  List<Favorite> loadFavorites() => _repository.getAll();

  List<Favorite> toggleFavorites({
    required List<Verse> verses,
    required int versionId,
  }) {
    final currentFavorites = _repository.getAll();
    final favoritesByReference = <(int, int, int, int), List<Favorite>>{};
    for (final favorite in currentFavorites) {
      final key = (
        favorite.versionId,
        favorite.bookId,
        favorite.chapter,
        favorite.fromVerse,
      );
      favoritesByReference.putIfAbsent(key, () => []).add(favorite);
    }

    final allAreFavorites =
        verses.every((verse) => favoritesByReference.containsKey((
              versionId,
              verse.bookId,
              verse.chapter,
              verse.verse,
            )));

    for (final verse in verses) {
      final key = (versionId, verse.bookId, verse.chapter, verse.verse);
      final existing = favoritesByReference[key] ?? [];
      if (allAreFavorites) {
        for (final favorite in existing) {
          _repository.delete(favorite);
        }
      } else if (existing.isEmpty) {
        _repository.save(
          Favorite(
            bookId: verse.bookId,
            chapter: verse.chapter,
            fromVerse: verse.verse,
            text: verse.text,
            versionId: versionId,
            date: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    }

    return _repository.getAll();
  }
}
