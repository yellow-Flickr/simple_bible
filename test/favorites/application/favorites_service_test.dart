import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/favorites/application/favorites_service.dart';
import 'package:simple_bible/favorites/domain/favorite.dart';
import 'package:simple_bible/favorites/domain/favorites_repository.dart';

void main() {
  group('FavoritesService', () {
    test('adds selected verses and removes them when toggled again', () {
      final repository = _FakeFavoritesRepository();
      final service = FavoritesService(repository);
      final verses = [
        _verse(bookId: 1, chapter: 2, verse: 3),
        _verse(bookId: 1, chapter: 2, verse: 4),
      ];

      final added = service.toggleFavorites(verses: verses, versionId: 100);

      expect(added, hasLength(2));
      expect(added.map((favorite) => favorite.fromVerse), [3, 4]);
      expect(
        service.toggleFavorites(verses: verses, versionId: 100),
        isEmpty,
      );
    });

    test('adds only missing selections when selection is partly favorited', () {
      final repository = _FakeFavoritesRepository([
        Favorite(
          bookId: 1,
          chapter: 2,
          fromVerse: 3,
          text: 'Existing',
          versionId: 100,
          date: 1,
        ),
      ]);
      final service = FavoritesService(repository);

      final favorites = service.toggleFavorites(
        verses: [
          _verse(bookId: 1, chapter: 2, verse: 3),
          _verse(bookId: 1, chapter: 2, verse: 4),
        ],
        versionId: 100,
      );

      expect(favorites, hasLength(2));
      expect(repository.deleted, isEmpty);
    });

    test('preserves favorites from other translations', () {
      final repository = _FakeFavoritesRepository([
        Favorite(
          bookId: 1,
          chapter: 2,
          fromVerse: 3,
          text: 'Other translation',
          versionId: 200,
          date: 1,
        ),
      ]);
      final service = FavoritesService(repository);

      final favorites = service.toggleFavorites(
        verses: [_verse(bookId: 1, chapter: 2, verse: 3)],
        versionId: 100,
      );

      expect(favorites, hasLength(2));
    });
  });
}

Verse _verse({
  required int bookId,
  required int chapter,
  required int verse,
}) {
  return Verse(
    id: verse,
    bookId: bookId,
    chapter: chapter,
    verse: verse,
    text: 'Verse $verse',
    translationId: 'KJV',
    bookName: 'Book',
    testament: 'Old',
  );
}

class _FakeFavoritesRepository implements FavoritesRepository {
  _FakeFavoritesRepository([List<Favorite>? favorites])
      : _favorites = favorites ?? [];

  final List<Favorite> _favorites;
  final List<Favorite> deleted = [];

  @override
  List<Favorite> getAll() => [..._favorites];

  @override
  void save(Favorite favorite) {
    _favorites.add(favorite);
  }

  @override
  void delete(Favorite favorite) {
    deleted.add(favorite);
    _favorites.remove(favorite);
  }
}
