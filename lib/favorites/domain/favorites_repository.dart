import 'package:simple_bible/favorites/domain/favorite.dart';

abstract interface class FavoritesRepository {
  List<Favorite> getAll();

  void save(Favorite favorite);

  void delete(Favorite favorite);
}
